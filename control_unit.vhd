library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is    Port ( 
        -- Inputs from Instruction & ALU
        op         : in  STD_LOGIC_VECTOR (6 downto 0);
        funct3     : in  STD_LOGIC_VECTOR (2 downto 0);
        funct7_5   : in  STD_LOGIC; -- Bit 30 of the instruction (used to differentiate ADD/SUB, SRL/SRA)
        Zero       : in  STD_LOGIC; -- From ALU
        
        -- Outputs to Datapath
        PCSrc      : out STD_LOGIC;
        ResultSrc  : out STD_LOGIC_VECTOR (1 downto 0);
        MemWrite   : out STD_LOGIC;
        ALUControl : out STD_LOGIC_VECTOR (3 downto 0);
        ALUSrc     : out STD_LOGIC;
        ALUSrcA    : out STD_LOGIC;
        ImmSrc     : out STD_LOGIC_VECTOR (1 downto 0);
        RegWrite   : out STD_LOGIC;
        Jump       : out STD_LOGIC;
        JalrMux    : out STD_LOGIC;
        Branch     : out STD_LOGIC
    );
end control_unit;

architecture Behavioral of control_unit is

    -- Internal signals
    signal ALUOp      : STD_LOGIC_VECTOR(1 downto 0);
    signal Branch_sig : STD_LOGIC;

begin

    Branch <= Branch_sig;

    ----------------------------------------------------------------------
    -- 1. MAIN DECODER
    -- Decodes the Opcode to set datapath multiplexers and enables
    ----------------------------------------------------------------------
    process(op)
    begin
        -- Default values to prevent latches
        RegWrite   <= '0';
        ImmSrc     <= "00";
        ALUSrc     <= '0';
        ALUSrcA    <= '0';
        MemWrite   <= '0';
        ResultSrc  <= "00";
        Branch_sig <= '0';
        Jump       <= '0';
        JalrMux    <= '0';
        ALUOp      <= "00";

        case op is
            -- R-Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
            when "0110011" => 
                RegWrite  <= '1';
                ALUSrc    <= '0'; -- Use Register RD2 for SrcB
                ALUSrcA   <= '0'; -- Use RD1 for SrcA
                ResultSrc <= "00"; -- Write back ALU result
                ALUOp     <= "10";

            -- I-Type Loads (LW, LB, LH, LBU, LHU)
            when "0000011" => 
                RegWrite  <= '1';
                ImmSrc    <= "00"; -- I-type Immediate
                ALUSrc    <= '1';  -- Use Immediate for SrcB
                ALUSrcA   <= '0';  -- Use RD1 for SrcA
                ResultSrc <= "01";  -- Write back Memory Data
                ALUOp     <= "00"; -- Force Addition for address calculation

            -- I-Type ALU (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
            when "0010011" => 
                RegWrite  <= '1';
                ImmSrc    <= "00"; -- I-type Immediate
                ALUSrc    <= '1';  -- Use Immediate for SrcB
                ALUSrcA   <= '0';  -- Use RD1 for SrcA
                ResultSrc <= "00";  -- Write back ALU result
                ALUOp     <= "10";

            -- S-Type (SW, SB, SH)
            when "0100011" =>
                ImmSrc    <= "01"; -- S-type Immediate
                ALUSrc    <= '1';  -- Use Immediate for SrcB
                ALUSrcA   <= '0';  -- Use RD1 for SrcA
                MemWrite  <= '1';  -- Enable Memory Write
                ALUOp     <= "00"; -- Force Addition for address calculation

            -- B-Type Branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            when "1100011" =>
                ImmSrc     <= "10"; -- B-type Immediate
                ALUSrc     <= '0';  -- Use Register RD2 for SrcB (comparison)
                ALUSrcA    <= '0';  -- Use RD1 for SrcA
                Branch_sig <= '1';  -- Enable Branch logic
                ALUOp      <= "01"; -- Force Subtraction for comparison

            -- U-Type LUI (Load Upper Immediate)
            when "0110111" =>
                RegWrite  <= '1';
                ALUSrc    <= '1';  -- Use Immediate
                ALUSrcA   <= '0';
                ResultSrc <= "11"; -- Write back ImmExt directly
                ALUOp     <= "00";

            -- U-Type AUIPC (Add Upper Immediate to PC)
            when "0010111" =>
                RegWrite  <= '1';
                ALUSrc    <= '1';  -- Use Immediate for SrcB
                ALUSrcA   <= '1';  -- Use PC for SrcA
                ResultSrc <= "00"; -- Write back ALU result (PC + ImmExt)
                ALUOp     <= "00"; -- ADD

            -- J-Type JAL (Jump and Link)
            when "1101111" =>
                RegWrite  <= '1';
                ALUSrc    <= '0';
                ALUSrcA   <= '0';
                ResultSrc <= "10"; -- Write back PC + 4 to rd
                Jump      <= '1';  -- Unconditional jump
                JalrMux   <= '0';  -- Target is PC + Imm
                ALUOp     <= "00";

            -- I-Type Jump JALR (Jump and Link Register)
            when "1100111" =>
                RegWrite  <= '1';
                ALUSrc    <= '1';
                ALUSrcA   <= '0';
                ResultSrc <= "10"; -- Write back PC + 4 to rd
                Jump      <= '1';  -- Unconditional jump
                JalrMux   <= '1';  -- Target is RD1 + Imm
                ALUOp     <= "00";

            when others =>
                null;
        end case;
    end process;

    ----------------------------------------------------------------------
    -- 2. ALU DECODER
    -- Looks at ALUOp, funct3, and funct7_5 to determine the 4-bit ALU operation
    ----------------------------------------------------------------------
    process(ALUOp, funct3, op, funct7_5)
    begin
        case ALUOp is
            when "00" => 
                ALUControl <= "0000"; -- ADD (Used for Load, Store, AUIPC, JAL, JALR)
                
            when "01" => 
                ALUControl <= "0001"; -- SUB (Used for Branch comparison)
                
            when "10" => 
                -- Look at funct3 to determine specific operation
                case funct3 is
                    when "000" => 
                        -- Differentiate between ADD and SUB using bit 30
                        -- Only R-Type SUB has funct7_5 = '1'
                        if (op = "0110011" and funct7_5 = '1') then
                            ALUControl <= "0001"; -- SUB
                        else
                            ALUControl <= "0000"; -- ADD / ADDI
                        end if;
                    when "001" => 
                        ALUControl <= "0010"; -- SLL / SLLI
                    when "010" => 
                        ALUControl <= "0011"; -- SLT / SLTI
                    when "011" => 
                        ALUControl <= "0100"; -- SLTU / SLTIU
                    when "100" => 
                        ALUControl <= "0101"; -- XOR / XORI
                    when "101" => 
                        -- SRL vs SRA using bit 30 (for both R-Type and I-Type)
                        if funct7_5 = '1' then
                            ALUControl <= "0111"; -- SRA / SRAI
                        else
                            ALUControl <= "0110"; -- SRL / SRLI
                        end if;
                    when "110" => 
                        ALUControl <= "1000"; -- OR / ORI
                    when "111" => 
                        ALUControl <= "1001"; -- AND / ANDI
                    when others => 
                        ALUControl <= "0000";
                end case;
                
            when others =>
                ALUControl <= "0000";
        end case;
    end process;

    ----------------------------------------------------------------------
    -- 3. PC LOGIC
    ----------------------------------------------------------------------
    PCSrc <= Branch_sig and Zero;

end Behavioral;