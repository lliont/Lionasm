using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using System.Drawing;
using System.Data;

namespace Lion_assembler
{
    public enum InstructionType : int
    {
        Undefined = -1,
        Directive = 1,
        Label = 2,
        Operand = 3,
        Equate = 4,
        DataByte = 5,
        DataWord = 6,
        DataAddress = 16
    }

    public enum OperandType : int
    {
        Undefined = -1,
        RegisterADirect = 1,
        RegisterAIndirect = 2,
        MemoryDirect = 3,
        MemoryIndirect = 4,
        ProgramCounter = 5,
        LabelDirect = 6,
        VariableDirect = 7,
        ConstantDirect = 8,
        RegisterBDirect = 9,
        MemoryNamedDirect = 10,
        MemoryNamedIndirect = 11,
        LabelIndirect = 12,
        VariableIndirect = 13,
        ConstantIndirect = 14,
        StatusRegister = 15,
        StackPointer =16
    }

    [Serializable]
    public sealed class InstructionLine
    {
        public int lno;
        public InstructionType type = InstructionType.Undefined;
        public string label = string.Empty;
        public int address = 0;
        public string hexAddress = string.Empty;
        public ushort len = 0;
        public string opcode = string.Empty;
        public string op1 = string.Empty;
        public string op2 = string.Empty;
        public OperandType op1t = OperandType.Undefined, op2t = OperandType.Undefined;
        public int opno = 0;
        public string word1 = string.Empty, word2 = string.Empty, word3 = string.Empty;
        public bool relative = false;
        public string variable = string.Empty;
        public List<int> values;
        public List<string> hexValues;
        public bool merge = false;
        public int page = 0;

        // serializers and enumerators like parameterless constructors
        public InstructionLine()
        {
            this.lno = 0;
        }

        public InstructionLine(int l)
        {
            this.lno = l;
        }
    }

    class aparser
    {
        public List<InstructionLine> instListArr = new List<InstructionLine>();     //  instruction list
        public List<InstructionLine> pageListArr = new List<InstructionLine>();     // page instruction list
        public Hashtable varList = new Hashtable();       // variable list
        public Hashtable constList = new Hashtable();  // constants list
        public Hashtable colorList = new Hashtable();     // color list
        public Hashtable instList = new Hashtable();    // instructions list
        public Hashtable dirList = new Hashtable();   // directive list
        public Hashtable lblList = new Hashtable();  // label list
        public string[] errList = { "Error 0", "<Bad syntax - missing value>", "<Bad Value>", "<Missing Parameter>",
                                      "<Bad parameter>","<Identifier already exists>", "<Unknown operation>", "<Number out of range>"  };
        private frmLionAsm LionAsmForm;
        private string[] sourceLinesArr = null;
        string delims = "\t\r\n, `"; //string delims2 = "\t\r\n,";
        string arith = "+-*/()0123456789";
        string opers = "+-*/()";
        string t;
        string validchar = "ABCDEFGHIJKLMNOPQRSTVUWXYZ0123456789.():_-$#+-*/><=?\\%@'";
        string validchar2 = "ABCDEFGHIJKLMNOPQRSTVUWXYZ0123456789.():_-$#+-*/><=?\\%@' ";
        int p = 0, l = 0, error = 0;
        ushort address = 32;
        int curpage = 0;
        //InstructionLine lastline;

        public void fill_clist()
        {
            colorList.Add("NOP", Color.Blue);
            colorList.Add("ADDI", Color.Blue);
            colorList.Add("CMPI", Color.Blue);
            colorList.Add("CMPI.B", Color.Blue);
            colorList.Add("SUBI", Color.Blue);
            colorList.Add("MOV", Color.Blue);
            colorList.Add("ADD", Color.Blue);
            colorList.Add("SUB", Color.Blue);
            colorList.Add("ADC", Color.Blue);
            colorList.Add("SWAP", Color.Blue);
            colorList.Add("MUL", Color.Blue);
            colorList.Add("CMP", Color.Blue);
            colorList.Add("CMPHL", Color.Blue);
            colorList.Add("AND", Color.Blue);
            colorList.Add("OR", Color.Blue);
            colorList.Add("XOR", Color.Blue);
            colorList.Add("NOT", Color.Blue);
            colorList.Add("SRA", Color.Blue);
            colorList.Add("SLA", Color.Blue);
            colorList.Add("SRL", Color.Blue);
            colorList.Add("SLL", Color.Blue);
            colorList.Add("SRLL", Color.Blue);
            colorList.Add("SLLL", Color.Blue);
            colorList.Add("ROL", Color.Blue);
            colorList.Add("JMP", Color.Blue);
            colorList.Add("JZ", Color.Blue);
            colorList.Add("JNZ", Color.Blue);
            colorList.Add("JO", Color.Blue);
            colorList.Add("JNO", Color.Blue);
            colorList.Add("JC", Color.Blue);
            colorList.Add("JNC", Color.Blue);
            colorList.Add("JN", Color.Blue);
            colorList.Add("JP", Color.Blue);
            colorList.Add("JBE", Color.Blue);
            colorList.Add("JB", Color.Blue);
            colorList.Add("JA", Color.Blue);
            colorList.Add("JAE", Color.Blue);
            colorList.Add("JR", Color.Blue);
            colorList.Add("JRZ", Color.Blue);
            colorList.Add("JRN", Color.Blue);
            colorList.Add("JRO", Color.Blue);
            colorList.Add("JRC", Color.Blue);
            colorList.Add("JSR", Color.Blue);
            colorList.Add("JRSR", Color.Blue);
            colorList.Add("RET", Color.Blue);
            colorList.Add("XCHG", Color.Blue);
            colorList.Add("PUSH", Color.Blue);
            colorList.Add("POP", Color.Blue);
            colorList.Add("INT", Color.Blue);
            colorList.Add("RETI", Color.Blue);
            colorList.Add("CLI", Color.Blue);
            colorList.Add("STI", Color.Blue);
            colorList.Add("OUT", Color.Blue);
            colorList.Add("OUT.B", Color.Blue);
            colorList.Add("IN", Color.Blue);
            colorList.Add("IN.B", Color.Blue);
            colorList.Add("INC", Color.Blue);
            colorList.Add("DEC.B", Color.Blue);
            colorList.Add("INC.B", Color.Blue);
            colorList.Add("DEC", Color.Blue);
            colorList.Add("JRBE", Color.Blue);
            colorList.Add("JRA", Color.Blue);
            colorList.Add("MOV.B", Color.Blue);
            colorList.Add("MOVHL", Color.Blue);
            colorList.Add("MOVLH", Color.Blue);
            colorList.Add("MOVHH", Color.Blue);
            colorList.Add("ADD.B", Color.Blue);
            colorList.Add("ADC.B", Color.Blue);
            colorList.Add("SUB.B", Color.Blue);
            colorList.Add("MUL.B", Color.Blue);
            colorList.Add("CMP.B", Color.Blue);
            colorList.Add("AND.B", Color.Blue);
            colorList.Add("OR.B", Color.Blue);
            colorList.Add("XOR.B", Color.Blue);
            colorList.Add("NOT.B", Color.Blue);
            colorList.Add("NEG.B", Color.Blue);
            colorList.Add("NEG", Color.Blue);
            colorList.Add("SRL.B", Color.Blue);
            colorList.Add("SLL.B", Color.Blue);
            colorList.Add("ROR.B", Color.Blue);
            colorList.Add("ROL.B", Color.Blue);
            colorList.Add("JRA.B", Color.Blue);
            colorList.Add("JLE", Color.Blue);
            colorList.Add("JG", Color.Blue);
            colorList.Add("JGE", Color.Blue);
            colorList.Add("JL", Color.Blue);
            colorList.Add("JRLE", Color.Blue);
            colorList.Add("JRL", Color.Blue);
            colorList.Add("JRG", Color.Blue);
            colorList.Add("JRGE", Color.Blue);
            colorList.Add("BTST", Color.Blue);
            colorList.Add("BSET", Color.Blue);
            colorList.Add("BCLR", Color.Blue);
            colorList.Add("MULU", Color.Blue);
            colorList.Add("MULU.B", Color.Blue);
            colorList.Add("JRNZ", Color.Blue);
            colorList.Add("MOVI", Color.Blue);
            colorList.Add("MOVI.B", Color.Blue);
            colorList.Add("SETX", Color.Blue);
            colorList.Add("JMPX", Color.Blue);
            colorList.Add("PUSHX", Color.Blue);
            colorList.Add("JRX", Color.Blue);
            colorList.Add("POPX", Color.Blue);
            colorList.Add("MOVX", Color.Blue);
            colorList.Add("SETSP", Color.Blue);
            colorList.Add("GETSP", Color.Blue);
            colorList.Add("MOVR", Color.Blue);
            colorList.Add("GADR", Color.Blue);
            colorList.Add("MOVR.B", Color.Blue);
            colorList.Add("JXAB", Color.Blue);
            colorList.Add("JXAW", Color.Blue);
            colorList.Add("JRXAB", Color.Blue);
            colorList.Add("JRXAW", Color.Blue);
            colorList.Add("SRSET", Color.Blue);
            colorList.Add("SRCLR", Color.Blue);
            colorList.Add("PRET", Color.Blue);
            colorList.Add("PJMP", Color.Blue);
            colorList.Add("PJSR", Color.Blue);
            colorList.Add("PMOV", Color.Blue);
            colorList.Add("SODP", Color.Blue);
            colorList.Add("SDP", Color.Blue);
            colorList.Add("SSP", Color.Blue);
            colorList.Add("MTOM", Color.Blue);
            colorList.Add("MTOI", Color.Blue);
            colorList.Add("ITOM", Color.Blue);
            colorList.Add("ITOI", Color.Blue);
            colorList.Add("NTOM", Color.Blue);
            colorList.Add("NTOI", Color.Blue);
            colorList.Add("END", Color.DarkMagenta);
            colorList.Add("ORG", Color.DarkMagenta);
            colorList.Add("DB", Color.DarkMagenta);
            colorList.Add("DW", Color.DarkMagenta);
            colorList.Add("DS", Color.DarkMagenta);
            colorList.Add("EQU", Color.DarkMagenta);
            colorList.Add("TEXT", Color.DarkMagenta);
            colorList.Add("DA", Color.DarkMagenta);
            colorList.Add("PAGE", Color.DarkMagenta);
        }

        public void fill_ilist()
        {
            instList.Add("NOP", 0);
            instList.Add("MOV", 2);
            instList.Add("ADD", 2);
            instList.Add("SUB", 2);
            instList.Add("ADC", 2);
            instList.Add("SWAP", 1);
            instList.Add("CMP", 2);
            instList.Add("AND", 2);
            instList.Add("OR", 2);
            instList.Add("XOR", 2);
            instList.Add("NOT", 1);
            instList.Add("SRA", 2);
            instList.Add("SLA", 2);
            instList.Add("SRL", 2);
            instList.Add("SLL", 2);
            instList.Add("SRLL", 2);
            instList.Add("SLLL", 2);
            //ilist.Add("ROR", 2);
            instList.Add("ROL", 2);
            instList.Add("JMP", 1);
            instList.Add("JZ", 1);
            instList.Add("JNZ", 1);
            instList.Add("JO", 1);
            instList.Add("JNO", 1);
            instList.Add("JC", 1);
            instList.Add("JNC", 1);
            instList.Add("JN", 1);
            instList.Add("JP", 1);
            instList.Add("JBE", 1);
            instList.Add("JB", 1);
            instList.Add("JA", 1);
            instList.Add("JAE", 1);
            instList.Add("JR", 1);
            instList.Add("JRZ", 1);
            instList.Add("JRN", 1);
            instList.Add("JRO", 1);
            instList.Add("JRC", 1);
            instList.Add("JSR", 1);
            instList.Add("JRSR", 1);
            instList.Add("RET", 0);
            instList.Add("XCHG", 2);
            instList.Add("PUSH", 1);
            instList.Add("POP", 1);
            instList.Add("INT", 1);
            instList.Add("RETI", 0);
            instList.Add("CLI", 0);
            instList.Add("STI", 0);
            instList.Add("OUT", 2);
            instList.Add("OUT.B", 2);
            instList.Add("IN", 2);
            instList.Add("IN.B", 2);
            instList.Add("INC", 1);
            instList.Add("INC.B", 1);
            instList.Add("DEC", 1);
            instList.Add("DEC.B", 1);
            instList.Add("JRBE", 1);
            instList.Add("JRA", 1);
            instList.Add("MOV.B", 2);
            instList.Add("MOVHL", 2);
            instList.Add("MOVLH", 2);
            instList.Add("MOVHH", 2);
            instList.Add("ADD.B", 2);
            instList.Add("ADC.B", 2);
            instList.Add("SUB.B", 2);
            //ilist.Add("MUL.B", 2);
            instList.Add("CMP.B", 2);
            instList.Add("CMPHL", 2);
            instList.Add("AND.B", 2);
            instList.Add("OR.B", 2);
            instList.Add("XOR.B", 2);
            instList.Add("NOT.B", 1);
            //ilist.Add("SRA.B", 2);
            //ilist.Add("SLA.B", 2);
            instList.Add("SRL.B", 2);
            instList.Add("SLL.B", 2);
            //ilist.Add("ROR.B", 2);
            //ilist.Add("ROL.B", 2);
            instList.Add("JRA.B", 1);
            instList.Add("JLE", 1);
            instList.Add("JL", 1);
            instList.Add("JRL", 1);
            instList.Add("JG", 1);
            instList.Add("JRLE", 1);
            instList.Add("JRG", 1);
            instList.Add("JGE", 1);
            instList.Add("JRGE", 1);
            instList.Add("BTST", 2);
            instList.Add("BSET", 2);
            instList.Add("BCLR", 2);
            instList.Add("MULU", 2);
            instList.Add("MULU.B", 2);
            instList.Add("JRNZ", 1);
            instList.Add("MOVI", 2);
            instList.Add("MOVI.B", 2);
            instList.Add("ADDI", 2);
            instList.Add("CMPI", 2);
            instList.Add("CMPI.B", 2);
            instList.Add("SUBI", 2);
            instList.Add("SETX", 1);
            instList.Add("JMPX", 1);
            instList.Add("JRX", 1);
            instList.Add("PUSHX", 0);
            instList.Add("MOVX", 1);
            instList.Add("POPX", 0);
            instList.Add("SETSP", 1);
            instList.Add("GETSP", 1);
            //ilist.Add("CMPHL", 1);
            instList.Add("MOVR", 2);
            instList.Add("MOVR.B", 2);
            instList.Add("GADR", 2);
            instList.Add("NEG", 1);
            instList.Add("NEG.B", 1);
            instList.Add("JXAB", 2);
            instList.Add("JXAW", 2);
            instList.Add("JRXAB", 2);
            instList.Add("JRXAW", 2);
            instList.Add("SRSET", 1);
            instList.Add("SRCLR", 1);
            instList.Add("PRET", 0);
            instList.Add("PJMP", 2);
            instList.Add("PJSR", 2);
            instList.Add("PMOV", 2);
            instList.Add("SODP", 1);
            instList.Add("SDP", 1);
            instList.Add("SSP", 1);
            instList.Add("MTOI", 2);
            instList.Add("MTOM", 2);
            instList.Add("ITOI", 2);
            instList.Add("ITOM", 2);
            instList.Add("NTOI", 2);
            instList.Add("NTOM", 2);
        }

        public void fill_dlist()
        {
            dirList.Add("END", Color.Green);
            dirList.Add("ORG", Color.Green);
            dirList.Add("DW", Color.Green);
            dirList.Add("DB", Color.Green);
            dirList.Add("DS", Color.Green);
            dirList.Add("TEXT", Color.Green);
            dirList.Add("DA", Color.Green);
            dirList.Add("PAGE", Color.Green);
        }

        public void fill_errlist()
        {

        }

        private bool get_next_token()
        {
            t = string.Empty;
            while ((p < sourceLinesArr[l].Length) && (delims.IndexOf(sourceLinesArr[l][p]) != -1))
            {
                p = p + 1;
            };
            while ((p < sourceLinesArr[l].Length) && (validchar.IndexOf(sourceLinesArr[l][p]) != -1))
            {
                t = t + sourceLinesArr[l][p];
                p = p + 1;
            };
            if (t.Length <= 0) return false; else return true;
        }

        private bool get_next_token2()
        {
            t = string.Empty;
            while ((p < sourceLinesArr[l].Length) && (delims.IndexOf(sourceLinesArr[l][p]) != -1))
            {
                p = p + 1;
            };
            while ((p < sourceLinesArr[l].Length) && (validchar2.IndexOf(sourceLinesArr[l][p]) != -1))
            {
                if (sourceLinesArr[l][p] != ' ') t = t + sourceLinesArr[l][p];
                p = p + 1;
            };
            if (t.Length <= 0) return false; else return true;
        }

        private bool get_next_char()
        {
            t = string.Empty;
            if (p < sourceLinesArr[l].Length)
            {
                t = t + sourceLinesArr[l][p];
                p = p + 1;
            };
            if (t.Length == 0 || t == "\"") return false; else return true;
        }

        private bool get_first_char()
        {
            t = string.Empty;
            while ((p < sourceLinesArr[l].Length) && (delims.IndexOf(sourceLinesArr[l][p]) != -1))
            {
                p = p + 1;
            };
            if (p < sourceLinesArr[l].Length)
            {
                t = t + sourceLinesArr[l][p];
                p = p + 1;
            };
            if (t.Length <= 0) return false; else return true;
        }

        private bool add_label(InstructionLine il)
        {
            il.type = InstructionType.Label;
            il.label = t.Substring(0, t.Length - 1);
            if (address % 2 == 1)
            {
                il.address = address + 1;
                LionAsmForm.errorbox.Text += " Warning Label " + t + " automaticly alinged to even address\r\n";
            }
            else il.address = address;
            if (varList.ContainsKey(il.label) || constList.ContainsKey(il.label)) { error = -5; return false; }
            try
            {
                lblList.Add(il.label, (int)address);
            }
            catch
            {
                error = -5;
                return false;
            }
            return true;
        }

        private OperandType parameter_type(string s)
        {
            int i;
            if (string.IsNullOrEmpty(s)) return OperandType.Undefined;
            if (s.Length == 2 && s[0] == 'A' && (s[1] >= '0' && s[1] < '8'))
            {
                return OperandType.RegisterADirect;
            }
            if (s.Length == 2 && s[0] == 'B' && (s[1] >= '0' && s[1] < '8'))
            {
                return OperandType.RegisterBDirect;
            }
            if (s.Length == 4 && s[0] == '(' && s[1] == 'A' && (s[2] >= '0' && s[2] < '8') && s[3] == ')')
            {
                return OperandType.RegisterAIndirect;
            }
            if (((s[0] >= '0' && s[0] <= '9') || s[0] == '-' || s[0] == '\'' || s[0] == '=' || s[0] == '@') && is_num(s))
            {
                return OperandType.MemoryDirect;
            }
            if (s[0] == '$')
            {
                try { Convert.ToInt32(s.Substring(1, s.Length - 1), 16); }
                catch { return OperandType.Undefined; }
                return OperandType.MemoryDirect;
            }
            if (s[0] == '#')
            {
                try { Convert.ToInt32(s.Substring(1, s.Length - 1), 2); }
                catch { return OperandType.Undefined; }
                return OperandType.MemoryDirect;
            }
            if (s[0] == '(')
            {
                if (((s[1] >= '0' && s[1] <= '9') || s[1] == '-' || s[1] == '=' || s[1] == '@') && is_num(s.Substring(1, s.Length - 2)))
                {
                    return OperandType.MemoryIndirect;
                }
                if (s[1] == '$')
                {
                    try { Convert.ToInt32(s.Substring(2, s.Length - 3), 16); }
                    catch { return OperandType.Undefined; }
                    return OperandType.MemoryIndirect;
                }
                if (s[1] == '#')
                {
                    try { Convert.ToInt32(s.Substring(2, s.Length - 3), 2); }
                    catch { return OperandType.Undefined; }
                    return OperandType.MemoryIndirect;
                }
            }

            if (s.Length > 1 && s[0] == 'P' && s[1] == 'C' && s.Length == 2)
            {
                return OperandType.ProgramCounter;
            }
            if (s.Length > 1 && s[0] == 'S' && s[1] == 'P' && s.Length == 2)
            {
                return OperandType.StackPointer;
            }
            if (s.Length > 1 && s[0] == 'S' && s[1] == 'R' && s.Length == 2)
            {
                return OperandType.StatusRegister;
            }
            if ((s[0] >= 'A' && s[0] <= 'Z') || (s[0] == '_') || (s[0] == '.'))
            {
                if (lblList.ContainsKey(s)) return OperandType.LabelDirect;
                if (constList.ContainsKey(s)) return OperandType.ConstantDirect;
                if (varList.ContainsKey(s)) return OperandType.VariableDirect;
                return OperandType.MemoryNamedDirect;
            }
            if (s.Length > 1 && s[0] == '(' && ((s[1] >= 'A' && s[1] <= 'Z') || (s[1] == '_') || (s[1] == '.')))
            {
                if (lblList.ContainsKey(s.Substring(1, s.Length - 2))) return OperandType.LabelIndirect;
                if (constList.ContainsKey(s.Substring(1, s.Length - 2))) return OperandType.ConstantIndirect;
                if (varList.ContainsKey(s.Substring(1, s.Length - 2))) return OperandType.VariableIndirect;
                return OperandType.MemoryNamedIndirect;
            }

            return OperandType.Undefined;
        }

        private int is_reg(string s)
        {
            if ((s[0] == 'A') && (s[1] >= '0' && s[1] < '8'))
            {
                return Convert.ToInt16(s[1] - '0');
            }
            return -1;
        }

        private int is_reg_ref(string s)
        {
            if (s[0] == '(' && s[1] == 'A' && (s[2] >= '0' && s[2] < '8') && s[3] == ')')
            {
                return Convert.ToInt16(s[2] - '0');
            }
            return -1;
        }

        // 1 Reg   2  (Reg)  3 num  4 (num)  5 PC  6 LABEL  7 variable  8 constant  9 Breg XXX
        // 10 To be filled  11 (TBF)  12 (L)  13 (V)  14 (C)  15 SR  16 SP 

        private bool mov(InstructionLine il)
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "0" + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "0" + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0000001" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0000001" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.ProgramCounter:
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = address;
                        il.word1 = "0111010" + s1 + "0000" + "00";
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "0000001" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.OperandType9:
                    //    r2 = is_reg(il.op2);
                    //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "0111001" + s1 + "0" + s2 + "00";
                    //    break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        il.word1 = "0000001" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "0000" + "01";
                        break;
                    case OperandType.MemoryNamedIndirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "0000" + "11";
                        break;
                    case OperandType.StackPointer  : il.len = 1;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1000101" + s1 + "0000" + "00";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.RegisterAIndirect)
            {
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000010" + s1 + "0" + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000010" + s1 + "0" + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0000010" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0000010" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "0000010" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        il.word1 = "0000010" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000010" + s1 + "0000" + "01";
                        break;
                    case OperandType.MemoryNamedIndirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000010" + s1 + "0000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryIndirect)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001001" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100000" + "0000000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100000" + "0000000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    //case OperandType.OperandType12:
                    //case OperandType.OperandType13:
                    //case OperandType.OperandType14:
                    //    il.len = 3; address += 2; r2 = conv_int(il.op2);
                    //    if (il.op2t == OperandType.OperandType6) r1 = (int)llist[il.op1];
                    //    if (il.op2t == OperandType.OperandType) r1 = (int)vlist[il.op1];
                    //    if (il.op2t == OperandType.OperandType) r1 = (int)constlist[il.op1];
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    //case OperandType.OperandType10: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001001" + "0000" + s2 + "01";
                    //    break;
                    //case OperandType.OperandType11: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001001" + "0000" + s2 + "01";
                    //    break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.LabelIndirect || il.op1t == OperandType.VariableIndirect | il.op1t == OperandType.ConstantIndirect)
            {
                if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001001" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100000" + "0000000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100000" + "0000000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryNamedIndirect)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001001" + "0000" + s2 + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100000" + "0000000" + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100000" + "0000000" + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 3;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1100000" + s1 + "0000" + "11";
                        break;
                    default:
                        return false;
                }
            } else
            if (il.op1t == OperandType.StackPointer)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001001" + "000" + "0" + s2 + "00";
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool add(InstructionLine il,char bwb='0')
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000011" + s1 + bwb + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000011" + s1 + bwb + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0000011" + s1 + bwb+"000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0000011" + s1 + bwb+ "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.ProgramCounter:
                    //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = address;
                    //    il.word1 = "0111010" + s1 + "0000" + "00";
                    //    break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "0000011" + s1 + bwb+ "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.OperandType9:
                    //    r2 = is_reg(il.op2);
                    //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "0111001" + s1 + "0" + s2 + "00";
                    //    break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        il.word1 = "0000011" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000011" + s1 + bwb + "000" + "01";
                        break;
                    case OperandType.MemoryNamedIndirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000011" + s1 + bwb+ "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.RegisterAIndirect)
            {
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1011110" + s2 + bwb + s1 + "00";
                        break;
                    //case OperandType.RegisterAIndirect:
                    //    r2 = is_reg_ref(il.op2);
                    //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1011110" + s1 + bwb + s2 + "10";
                    //    break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "1011010" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.MemoryIndirect:
                    //    il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                    //    il.word1 = "1011110" + s1 + bwb + "000" + "11";
                    //    il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1011010" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.LabelIndirect:
                    //case OperandType.VariableIndirect:
                    //case OperandType.ConstantIndirect:
                    //    il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    //    s2 = il.op2.Substring(1, il.op2.Length - 2);
                    //    if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                    //    if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                    //    if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                    //    il.word1 = "1011110" + s1 + bwb + "000" + "11";
                    //    il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1011010" + s1 + bwb + "000" + "01";
                        break;
                    //case OperandType.MemoryNamedIndirect: il.len = 2;
                    //    s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    //    il.word1 = "1011110" + s1 + bwb + "000" + "11";
                    //    break;
                    default:
                        return false;
                }
            }

            else if (il.op1t == OperandType.LabelIndirect || il.op1t == OperandType.VariableIndirect | il.op1t == OperandType.ConstantIndirect)
            {
                if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1011100" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100100" + "0000000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100100" + "000"+bwb+"000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryNamedIndirect)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1011100" + "0000" + s2 + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100100" + "000" + bwb + "000" + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100100" + "000" + bwb + "000" + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 3;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1100100" + s1 + bwb + "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryIndirect)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1011100" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100100" + "0000000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100100" + "0000000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.StackPointer)
            {
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1011011" + "000" + "0" + s2 + "00";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "1011011" + "000"+"0" + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1011011" + "000"+"0" + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool sub(InstructionLine il, char bwb = '0')
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000100" + s1 + bwb + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000100" + s1 + bwb + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0000100" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0000100" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.ProgramCounter:
                    //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = address;
                    //    il.word1 = "0111010" + s1 + "0000" + "00";
                    //    break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "0000100" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.OperandType9:
                    //    r2 = is_reg(il.op2);
                    //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "0111001" + s1 + "0" + s2 + "00";
                    //    break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        il.word1 = "0000100" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000100" + s1 + bwb + "000" + "01";
                        break;
                    case OperandType.MemoryNamedIndirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000100" + s1 + bwb + "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.RegisterAIndirect)
            {
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1011111" + s2 + bwb + s1 + "00";
                        break;
                    //case OperandType.RegisterAIndirect:
                    //    r2 = is_reg_ref(il.op2);
                    //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1011111" + s1 + bwb + s2 + "10";
                    //    break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0110100" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.MemoryIndirect:
                    //    il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                    //    il.word1 = "1011111" + s1 + bwb + "000" + "11";
                    //    il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "0110100" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.LabelIndirect:
                    //case OperandType.VariableIndirect:
                    //case OperandType.ConstantIndirect:
                    //    il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    //    s2 = il.op2.Substring(1, il.op2.Length - 2);
                    //    if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                    //    if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                    //    if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                    //    il.word1 = "1011111" + s1 + bwb + "000" + "11";
                    //    il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0110100" + s1 + bwb + "000" + "01";
                        break;
                    //case OperandType.MemoryNamedIndirect: il.len = 2;
                    //    s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    //    il.word1 = "1011111" + s1 + bwb + "000" + "11";
                    //    break;
                    default:
                        return false;
                }
            }

            else if (il.op1t == OperandType.LabelIndirect || il.op1t == OperandType.VariableIndirect | il.op1t == OperandType.ConstantIndirect)
            {
                if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1011100" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100101" + "0000000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100101" + "000" + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryNamedIndirect)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1011101" + "0000" + s2 + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100101" + "000" + bwb + "000" + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100101" + "000" + bwb + "000" + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 3;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1100101" + s1 + bwb + "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryIndirect)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1011101" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100101" + "0000000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100101" + "0000000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.StackPointer)
            {
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0111010" + "000" + "0" + s2 + "00";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0111010" + "000" + "0" + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "0111010" + "000" + "0" + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool movb(InstructionLine il)
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "1" + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "1" + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0000001" + s1 + "1000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0000001" + s1 + "1000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "0000001" + s1 + "1000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        il.word1 = "0000001" + s1 + "1000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "1000" + "01";
                        break;
                    case OperandType.MemoryNamedIndirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "1000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            // 1 Reg   2  (Reg)  3 num  4 (num)  5 PC  6 LABEL  7 variable  8 constant  9 Breg XXX
            // 10 To be filled  11 (TBF)  12 (L)  13 (V)  14 (C)  15 SR  16 SP 
            else if (il.op1t == OperandType.RegisterAIndirect)
            {
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001100" + s1 + "1" + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001100" + s1 + "1" + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0001100" + s1 + "1000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0001100" + s1 + "1000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "0001100" + s1 + "1000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        il.word1 = "0001100" + s1 + "1000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0001100" + s1 + "1000" + "01";
                        break;
                    case OperandType.MemoryNamedIndirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0001100" + s1 + "1000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryIndirect)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001010" + "0001" + s2 + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100001" + "0001000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100001" + "0001000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    //case OperandType.OperandType10: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001010" + "0000" + s2 + "11";
                    //    break;
                    //case OperandType.OperandType11: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001010" + "0000" + s2 + "11";
                    //    break;
                    default:
                        return false;
                }
            }
            // 1 Reg   2  (Reg)  3 num  4 (num)  5 PC  6 LABEL  7 variable  8 constant  9 Breg XXX
            // 10 To be filled  11 (TBF)  12 (L)  13 (V)  14 (C)  15 SR  16 SP 
            else if (il.op1t == OperandType.LabelIndirect || il.op1t == OperandType.VariableIndirect | il.op1t == OperandType.ConstantIndirect)
            {
                if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001010" + "0001" + s2 + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100001" + "0001000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100001" + "0001000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    //case OperandType.MemoryNamedDirect:
                    //case OperandType.MemoryNamedIndirect:
                    //break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryNamedIndirect)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001010" + "0001" + s2 + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100001" + "0001000" + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100001" + "0001000" + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool cmpb(InstructionLine il, char bwb)
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001110" + s1 + bwb + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001110" + s1 + bwb + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0001110" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0001110" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "0001110" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        il.word1 = "0001110" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0001110" + s1 + bwb + "000" + "01";
                        break;
                    case OperandType.MemoryNamedIndirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0001110" + s1 + bwb + "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.RegisterAIndirect)
            {
                // 1 Reg   2  (Reg)  3 num  4 (num)  5 PC  6 LABEL  7 variable  8 constant  9 Breg XXX
                // 10 To be filled  11 (TBF)  12 (L)  13 (V)  14 (C)  15 SR  16 SP 
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0100001" + s1 + bwb + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0100001" + s1 + bwb + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0100001" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.OperandType4:
                    //    il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                    //    il.word1 = "0100001" + s1 + bwb + "000" + "11";
                    //    il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "0100001" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.OperandType12:
                    //case OperandType.OperandType13:
                    //case OperandType.OperandType14:
                    //    il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    //    s2 = il.op2.Substring(1, il.op2.Length - 2);
                    //    if (il.op2t == OperandType.OperandType12) r2 = (int)llist[s2];
                    //    if (il.op2t == OperandType.OperandType13) r2 = (int)vlist[s2];
                    //    if (il.op2t == OperandType.OperandType14) r2 = (int)constlist[s2];
                    //    il.word1 = "0100001" + s1 + bwb + "000" + "11";
                    //    il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0100001" + s1 + bwb + "000" + "01";
                        break;
                    case OperandType.MemoryNamedIndirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0100001" + s1 + bwb + "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryIndirect)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001101" + "000" + bwb + s2 + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    //case OperandType.OperandType10: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001010" + "0000" + s2 + "11";
                    //    break;
                    //case OperandType.OperandType11: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001010" + "0000" + s2 + "11";
                    //    break;
                    default:
                        return false;
                }
            }
            // 1 Reg   2  (Reg)  3 num  4 (num)  5 PC  6 LABEL  7 variable  8 constant  9 Breg XXX
            // 10 To be filled  11 (TBF)  12 (L)  13 (V)  14 (C)  15 SR  16 SP 
            else if (il.op1t == OperandType.LabelIndirect || il.op1t == OperandType.VariableIndirect | il.op1t == OperandType.ConstantIndirect)
            {
                if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001101" + "000" + bwb + s2 + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    //case OperandType.MemoryNamedDirect:
                    //case OperandType.MemoryNamedIndirect:
                    //    break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryNamedIndirect)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001101" + "000" + bwb + s2 + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 3;
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool gen1(InstructionLine il, string op, char bwb='0')  // two params first a register
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + bwb + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + bwb + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = op + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = op + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = op + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        il.word1 = op + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + bwb + "000" + "01";
                        break;
                    case OperandType.MemoryNamedIndirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + bwb + "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool gen2(InstructionLine il, string op, char bwb='0')  // one param always a register bwb
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                il.word1 = op + s1 + bwb + "00000";
            }
            //else
            //    if (il.op1t == OperandType.OperandType9 && (op == "1000111" || op == "1001000"))
            //    {
            //        op2 = op;
            //        if (op == "1000111") op2 = "1100000";
            //        if (op == "1001000") op2 = "1100001";
            //        r1 = is_reg(il.op1);
            //        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //        il.word1 = op2 + s1 + "000000";
            //    }
            else return false;
            return true;
        }

        private bool gen3(InstructionLine il, string op)  // two params second 0-15
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        switch (il.opcode)
                        {
                            case "BTST":
                                il.word1 = "0001011" + s1 + "0" + s2 + "00";
                                break;
                            case "BSET":
                                il.word1 = "1010001" + s1 + "0" + s2 + "00";
                                break;
                            case "BCLR":
                                il.word1 = "0011110" + s1 + "0" + s2 + "00";
                                break;
                            default:
                                return false;
                        }
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        if (r2 > 15 || r2 < 0) { error = -7; return false; }
                        if (il.opcode == "ROR") r2 = 16 - r2;
                        s2 = Convert.ToString(r2, 2).PadLeft(4, '0');
                        il.word1 = op + s1 + s2 + "00";
                        break;
                    case OperandType.ConstantDirect:
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        if (r2 > 15 || r2 < 0) { error = -7; return false; }
                        if (il.opcode == "ROR") r2 = 16 - r2;
                        s2 = Convert.ToString(r2, 2).PadLeft(4, '0');
                        il.word1 = op + s1 + s2 + "00";
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool gen4(InstructionLine il, string op, char bwb='0')  // two params regs
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect || il.op1t == OperandType.RegisterBDirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                    case OperandType.RegisterBDirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + bwb + s2 + "00";
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool gen5(InstructionLine il, string op, char bwb='0')  // one param for mainly for jumps
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t == OperandType.Undefined) return false;
            switch (il.op1t)
            {
                case OperandType.RegisterADirect:
                    r1 = is_reg(il.op1);
                    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    il.word1 = op + "000"+ bwb + s1 + "00";
                    break;
                case OperandType.RegisterAIndirect:
                    r1 = is_reg_ref(il.op1);
                    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    il.word1 = op + "000"+ bwb + s1 + "10";
                    break;
                case OperandType.MemoryDirect:
                    il.len = 2; r1 = conv_int(il.op1);
                    il.word1 = op + "000" +bwb+"000" + "01";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case OperandType.MemoryIndirect:
                    il.len = 2; r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                    il.word1 = op + "000"+bwb+"000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case OperandType.LabelDirect:
                case OperandType.VariableDirect:
                case OperandType.ConstantDirect:
                    il.len = 2;
                    if (il.op1t == OperandType.LabelDirect) r1 = (int)lblList[il.op1];
                    if (il.op1t == OperandType.VariableDirect) r1 = (int)varList[il.op1];
                    if (il.op1t == OperandType.ConstantDirect) r1 = (int)constList[il.op1];
                    il.word1 = op + "000" +bwb + "000" + "01";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case OperandType.LabelIndirect:
                case OperandType.VariableIndirect:
                case OperandType.ConstantIndirect:
                    il.len = 2;
                    s1 = il.op1.Substring(1, il.op1.Length - 2);
                    if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[s1];
                    if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[s1];
                    if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[s1];
                    il.word1 = op + "000"+bwb+"000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case OperandType.MemoryNamedDirect:
                    il.len = 2;
                    il.word1 = op + "000"+bwb+"000" + "01";
                    break;
                case OperandType.MemoryNamedIndirect:
                    il.len = 2;
                    il.word1 = op + "000"+bwb+"000" + "11";
                    break;
                default:
                    return false;
            }
            return true;
        }

        private bool gen6(InstructionLine il, string op, char bwb='0')  // one param for relative jumps
        {
            int r1 = 0, ii = 0; string s1;
            il.op1t = parameter_type(il.op1);
            il.relative = true;
            if (il.op1t == OperandType.Undefined) return false;
            ii = (int)address;
            switch (il.op1t)
            {
                case OperandType.RegisterADirect:
                    r1 = is_reg(il.op1);
                    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    il.word1 = op + "000"+ bwb + s1 + "00";
                    break;
                case OperandType.RegisterAIndirect:
                    r1 = is_reg_ref(il.op1);
                    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    il.word1 = op + "000" + bwb + s1 + "10";
                    break;
                case OperandType.MemoryDirect:
                    il.len = 2; r1 = conv_int(il.op1); //r1=address; 
                    il.word1 = op + "000"+ bwb+"000" + "01";
                    il.word2 = Convert.ToString((Int16)r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case OperandType.MemoryIndirect:
                    il.word2 = Convert.ToString((Int16)r1, 2).PadLeft(16, '0');
                    il.len = 2; r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                    il.word1 = op + "000"+ bwb+"000" + "11";
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case OperandType.LabelDirect:
                case OperandType.VariableDirect:
                case OperandType.ConstantDirect:
                    il.len = 2;
                    if (il.op1t == OperandType.LabelDirect) { r1 = (int)lblList[il.op1]; r1 = r1 - ii - 4; }
                    if (il.op1t == OperandType.VariableDirect) { r1 = (int)varList[il.op1]; r1 = r1 - ii - 4; }
                    if (il.op1t == OperandType.ConstantDirect) { r1 = (int)constList[il.op1]; r1 = r1 - ii - 4; }
                    il.word1 = op + "000"+ bwb +"000" + "01";
                    il.word2 = Convert.ToString((Int16)r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case OperandType.LabelIndirect:
                case OperandType.VariableIndirect:
                case OperandType.ConstantIndirect:
                    il.len = 2;
                    s1 = il.op1.Substring(1, il.op1.Length - 2);
                    if (il.op1t == OperandType.LabelIndirect) { r1 = (int)lblList[s1]; }
                    if (il.op1t == OperandType.VariableIndirect) { r1 = (int)varList[s1]; }
                    if (il.op1t == OperandType.ConstantIndirect) { r1 = (int)constList[s1]; }
                    il.word1 = op + "000"+ bwb+"000" + "11";
                    il.word2 = Convert.ToString((Int16)r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case OperandType.MemoryNamedDirect:
                    il.len = 2;
                    il.word1 = op + "000"+ bwb+"000" + "01";
                    break;
                case OperandType.MemoryNamedIndirect:
                    il.len = 2;
                    il.word1 = op + "000"+ bwb+"000" + "11";
                    break;
                default:
                    return false;
            }
            return true;
        }

        private bool gen7(InstructionLine il, string op, char bwb = '0')  // two param first register, relative 
        {
            int r1 = 0, ii = 0; string s1;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            il.relative = true;
            if (il.op1t!=OperandType.RegisterADirect || il.op2t == OperandType.Undefined) return false;
            ii = (int)address;
            r1 = is_reg(il.op1); s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            switch (il.op2t)
            {
                //case OperandType.RegisterADirect:
                //    r1 = is_reg(il.op1);
                //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                //    il.word1 = op + "000" + bwb + s1 + "00";
                //    break;
                //case OperandType.RegisterAIndirect:
                //    r1 = is_reg_ref(il.op1);
                //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                //    il.word1 = op + "000" + bwb + s1 + "10";
                //    break;
                case OperandType.MemoryDirect:
                    il.len = 2; 
                    il.word1 = op + s1 + bwb + "000" + "01";
                    r1 = conv_int(il.op2);
                    il.word2 = Convert.ToString((Int16)r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                //case OperandType.MemoryIndirect:
                //    il.word2 = Convert.ToString((Int16)r1, 2).PadLeft(16, '0');
                //    il.len = 2; r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                //    il.word1 = op + "000" + bwb + "000" + "11";
                //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                //    break;
                case OperandType.LabelDirect:
                case OperandType.VariableDirect:
                case OperandType.ConstantDirect:
                    il.len = 2;
                    if (il.op2t == OperandType.LabelDirect) { r1 = (int)lblList[il.op2]; r1 = r1 - ii - 4; }
                    if (il.op2t == OperandType.VariableDirect) { r1 = (int)varList[il.op2]; r1 = r1 - ii - 4; }
                    if (il.op2t == OperandType.ConstantDirect) { r1 = (int)constList[il.op2]; r1 = r1 - ii - 4; }
                    il.word1 = op + s1 + bwb + "000" + "01";
                    il.word2 = Convert.ToString((Int16)r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                //case OperandType.LabelIndirect:
                //case OperandType.VariableIndirect:
                //case OperandType.ConstantIndirect:
                //    il.len = 2;
                //    s1 = il.op1.Substring(1, il.op1.Length - 2);
                //    if (il.op1t == OperandType.LabelIndirect) { r1 = (int)lblList[s1]; }
                //    if (il.op1t == OperandType.VariableIndirect) { r1 = (int)varList[s1]; }
                //    if (il.op1t == OperandType.ConstantIndirect) { r1 = (int)constList[s1]; }
                //    il.word1 = op + "000" + bwb + "000" + "11";
                //    il.word2 = Convert.ToString((Int16)r1, 2).PadLeft(16, '0');
                //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                //    break;
                case OperandType.MemoryNamedDirect:
                    il.len = 2;
                    il.word1 = op + s1 + bwb + "000" + "01";
                    break;
                //case OperandType.MemoryNamedIndirect:
                //    il.len = 2;
                //    il.word1 = op + "000" + bwb + "000" + "11";
                //    break;
                default:
                    return false;
            }
            return true;
        }

        // 1 Reg   2  (Reg)  3 num  4 (num)  5 PC  6 LABEL  7 variable  8 constant  9 Breg XXX
        // 10 To be filled  11 (TBF)  12 (L)  13 (V)  14 (C)  15 SR  16 SP 

        private bool movr(InstructionLine il, char bwb)
        {
            int r1 = 0, r2 = 0, ii; string s1, s2;
            ii = (int)address;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            il.relative = true;
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s2 + bwb + s1 + "10";
                        break;
                    case OperandType.MemoryDirect:  // GADR
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "1111011" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "1111011" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelDirect:  // GADR
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        r2 = r2 - ii - 4;
                        il.word1 = "1111011" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 2;  // GADR
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s1 + "0000" + "01";
                        break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        r2 = r2 - ii - 4;
                        il.word1 = "1111011" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedIndirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s1 + bwb + "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.RegisterAIndirect)
            {
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s1 + bwb + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s1 + bwb + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "1111011" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1111011" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedDirect: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s1 + bwb + "000" + "01";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryIndirect)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1111100"  + "000" + bwb + s2 + "11";
                        r2 = r2 - ii - 4;
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.OperandType3:
                    //    il.len = 3; r2 = conv_int(il.op2);
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    //case OperandType.OperandType6:
                    //case OperandType.OperandType7:
                    //case OperandType.OperandType8:
                    //    il.len = 3;
                    //    if (il.op2t == OperandType.OperandType6) r2 = (int)llist[il.op2];
                    //    if (il.op2t == OperandType.OperandType7) r2 = (int)vlist[il.op2];
                    //    if (il.op2t == OperandType.OperandType8) r2 = (int)constlist[il.op2];
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    //case OperandType.OperandType12:
                    //case OperandType.OperandType13:
                    //case OperandType.OperandType14:
                    //    il.len = 3; address += 2; r2 = conv_int(il.op2);
                    //    if (il.op2t == OperandType.OperandType6) r1 = (int)llist[il.op1];
                    //    if (il.op2t == OperandType.OperandType7) r1 = (int)vlist[il.op1];
                    //    if (il.op2t == OperandType.OperandType8) r1 = (int)constlist[il.op1];
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    //case OperandType.OperandType10: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001001" + "0000" + s2 + "01";
                    //    break;
                    //case OperandType.OperandType11: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001001" + "0000" + s2 + "01";
                    //    break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.LabelIndirect || il.op1t == OperandType.VariableIndirect | il.op1t == OperandType.ConstantIndirect)
            {
                if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1111100" + "000" + bwb + s2 + "11";
                        r1 = r1 - ii - 4;
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.OperandType3:
                    //    il.len = 3; r2 = conv_int(il.op2);
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    //case OperandType.OperandType6:
                    //case OperandType.OperandType7:
                    //case OperandType.OperandType8:
                    //    il.len = 3;
                    //    if (il.op2t == OperandType.OperandType6) r2 = (int)llist[il.op2];
                    //    if (il.op2t == OperandType.OperandType7) r2 = (int)vlist[il.op2];
                    //    if (il.op2t == OperandType.OperandType8) r2 = (int)constlist[il.op2];
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryNamedIndirect)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1111100" + "000" + bwb + s2 + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool inc(InstructionLine il, char bwb)  // one param always a register bwb
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t == OperandType.Undefined) return false;
            switch (il.op1t)
            {
                case OperandType.RegisterADirect:
                    if (il.op1t == OperandType.RegisterADirect)
                    {
                        r1 = is_reg(il.op1);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1000111" + s1 + bwb + "00000";
                    }
                    break;
                case OperandType.MemoryIndirect:
                    il.len = 3; r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                    il.word1 = "1100100" + "000" + bwb + "000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    il.word3 = "1".PadLeft(16, '0');
                    break;
                case OperandType.MemoryNamedIndirect:
                    il.len = 3;
                    il.word1 = "1100100" + "000" + bwb + "000" + "11";
                    il.word3 = "1".PadLeft(16, '0');
                    break;
                case OperandType.LabelIndirect:
                case OperandType.VariableIndirect:
                case OperandType.ConstantIndirect:
                    il.len = 3;
                    s1 = il.op1.Substring(1, il.op1.Length - 2);
                    if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[s1];
                    if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[s1];
                    if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[s1];
                    il.word1 = "1100100" + "000" + bwb + "000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    il.word3 = "1".PadLeft(16, '0');
                    break;
                //else
                //    if (il.op1t == OperandType.OperandType9 && (op == "1000111" || op == "1001000"))
                //    {
                //        op2 = op;
                //        if (op == "1000111") op2 = "1100000";
                //        if (op == "1001000") op2 = "1100001";
                //        r1 = is_reg(il.op1);
                //        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                //        il.word1 = op2 + s1 + "000000";
                //    }
                default: return false;
            }
            return true;
        }

        private bool dec(InstructionLine il, char bwb)  // one param always a register bwb
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t == OperandType.Undefined) return false;
            switch (il.op1t)
            {
                case OperandType.RegisterADirect:
                    if (il.op1t == OperandType.RegisterADirect)
                    {
                        r1 = is_reg(il.op1);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1001000" + s1 + bwb + "00000";
                    }
                    break;
                case OperandType.MemoryIndirect:
                    il.len = 3; r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                    il.word1 = "1100101" + "000" + bwb + "000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    il.word3 = "1".PadLeft(16, '0');
                    break;
                case OperandType.MemoryNamedIndirect:
                    il.len = 3;
                    il.word1 = "1100101" + "000" + bwb + "000" + "11";
                    il.word3 = "1".PadLeft(16, '0');
                    break;
                case OperandType.LabelIndirect:
                case OperandType.VariableIndirect:
                case OperandType.ConstantIndirect:
                    il.len = 3;
                    s1 = il.op1.Substring(1, il.op1.Length - 2);
                    if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[s1];
                    if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[s1];
                    if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[s1];
                    il.word1 = "1100101" + "000" + bwb + "000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    il.word3 = "1".PadLeft(16, '0');
                    break;
                //else
                //    if (il.op1t == OperandType.OperandType9 && (op == "1000111" || op == "1001000"))
                //    {
                //        op2 = op;
                //        if (op == "1000111") op2 = "1100000";
                //        if (op == "1001000") op2 = "1100001";
                //        r1 = is_reg(il.op1);
                //        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                //        il.word1 = op2 + s1 + "000000";
                //    }
                default: return false;
            }
            return true;
        }

        private bool inter(InstructionLine il, string op, char bit8 = '0')  // one param for 0-16
        {
            int r1 = 0;
            il.op1t = parameter_type(il.op1);
            if (il.op1t == OperandType.Undefined) return false;
            switch (il.op1t)
            {
                case OperandType.MemoryDirect:
                    il.len = 1; r1 = conv_int(il.op1);
                    if (r1 > 15 || r1 < 0) { error = -7; return false; }
                    il.word1 = op + bit8 + "00" + Convert.ToString(r1, 2).PadLeft(4, '0') + "00";
                    break;
                case OperandType.ConstantDirect:
                    il.len = 1;
                    if (il.op1t == OperandType.ConstantDirect) r1 = (int)constList[il.op1];
                    if (r1 > 15 || r1 < 0) { error = -7; return false; }
                    il.word1 = op + bit8 + "00" + Convert.ToString(r1, 2).PadLeft(4, '0') + "00";
                    break;
                default:
                    return false;
            }
            return true;
        }

        private bool push(InstructionLine il)
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                il.word1 = "0111011" + s1 + "000000";
            }
            else if (il.op1t == OperandType.RegisterAIndirect)
            {
                r1 = is_reg_ref(il.op1);
                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                il.word1 = "01110110000" + s1 + "10";
            }
            else if (il.op1t == OperandType.MemoryDirect)
            {
                il.len = 2; r1 = conv_int(il.op1);
                il.word1 = "0111011" + "000000001";
                il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                il.word2 = il.word2.Substring(il.word2.Length - 16);
            }
            else if (il.op1t == OperandType.LabelDirect || il.op1t == OperandType.VariableDirect | il.op1t == OperandType.ConstantDirect)
            {
                if (il.op1t == OperandType.LabelDirect) r1 = (int) lblList[il.op1];
                if (il.op1t == OperandType.VariableDirect) r1 = (int) varList[il.op1];
                if (il.op1t == OperandType.ConstantDirect) r1 = (int) constList[il.op1];
                il.len = 2; // r1 = conv_int(il.op1);
                il.word1 = "0111011" + "000000001";
                il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                il.word2 = il.word2.Substring(il.word2.Length - 16);
            }
             else if (il.op1t==OperandType.MemoryIndirect) {
                    il.len = 2; r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                    il.word1 = "0111011" + "0000000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
            }
             else if (il.op1t == OperandType.LabelIndirect || il.op1t == OperandType.VariableIndirect | il.op1t == OperandType.ConstantIndirect)
             {
                 il.len = 2;
                 s1 = il.op1.Substring(1, il.op1.Length - 2);
                 if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[s1];
                 if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[s1];
                 if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[s1];
                 il.word1 = "0111011" + "0000000" + "11";
                 il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                 il.word2 = il.word2.Substring(il.word2.Length - 16);
             }
             else if (il.op1t == OperandType.StatusRegister)
             {
                 r1 = is_reg(il.op1);
                 il.len = 1;
                 il.word1 = "0111101" + "000100000";
             }
             else return false;
            return true;
        }

        private bool pop(InstructionLine il)
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                il.word1 = "1000000" + s1 + "000000";
            }
            //else if (il.op1t == OperandType.ProgramCounter)
            //{
            //    r1 = is_reg(il.op1);
            //    il.len = 1;
            //    il.word1 = "0111110" + "000000000";
            //}
            else if (il.op1t == OperandType.StatusRegister)
            {
                r1 = is_reg(il.op1);
                il.len = 1;
                il.word1 = "0111110" + "000100000";
            }
            else return false;
            return true;
        }

        private bool outop(InstructionLine il, char bwb = '0')
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000111" + s1 + bwb + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1010110" + s1 + bwb + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "1010110" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //        case OperandType.MemoryIndirect:
                    //            il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                    //            il.word1 = "0000111" + s1 + "0000" + "11";
                    //            il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //            il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //            break;
                    //        case OperandType.LabelDirect:
                    //        case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                    case OperandType.VariableDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');

                        //if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1010110" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //        case OperandType.LabelIndirect:
                    //        case OperandType.VariableIndirect:
                    //        case OperandType.ConstantIndirect:
                    //            il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    //            s2 = il.op2.Substring(1, il.op2.Length - 2);
                    //            if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                    //            if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                    //            if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                    //            il.word1 = "0000111" + s1 + "0000" + "11";
                    //            il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //            il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //            break;
                    //        //case OperandType.MemoryNamedDirect:
                    //        //case OperandType.MemoryNamedIndirect:
                    //        //    break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryDirect)
            {
                r1 = conv_int(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000111" + bwb + "000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                    //case OperandType.ConstantDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100011" + "000"+ bwb+"00001";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.ConstantDirect:
                        il.len = 3; r2 = (int)constList[il.op2];
                        il.word1 = "1100011" + "000"+ bwb+"00001";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    default:
                        return false;
                    //case OperandType.MemoryNamedDirect:
                    //case OperandType.MemoryNamedIndirect:
                    //    break;
                }
            }
            else if (il.op1t == OperandType.ConstantDirect)
            {
                if (il.op1t == OperandType.ConstantDirect) r1 = (int)constList[il.op1];
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000111" + "000" + bwb + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100011" + "000"+ bwb+"00001";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case OperandType.ConstantDirect:
                        il.len = 3; r2 =(int)constList[il.op2];
                        il.word1 = "1100011" + "000"+ bwb+"00001";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    //case OperandType.MemoryNamedDirect:
                    //case OperandType.MemoryNamedIndirect:
                    //    break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool outop_b(InstructionLine il, char bwb = '0')
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1010111" + s1 + bwb + s2 + "00";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "1011000" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.ConstantDirect:
                    case OperandType.VariableDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');

                        //if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1011000" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryDirect)
            {
                r1 = conv_int(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1010111" + bwb + "000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.MemoryDirect:
                    //    //case OperandType.ConstantDirect:
                    //    il.len = 3; r2 = conv_int(il.op2);
                    //    il.word1 = "1100011" + "000" + bwb + "00001";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    //case OperandType.ConstantDirect:
                    //    il.len = 3; r2 = (int)constList[il.op2];
                    //    il.word1 = "1100011" + "000" + bwb + "00001";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.ConstantDirect)
            {
                if (il.op1t == OperandType.ConstantDirect) r1 = (int)constList[il.op1];
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1010111" + "000" + bwb + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.MemoryDirect:
                    //    il.len = 3; r2 = conv_int(il.op2);
                    //    il.word1 = "1100011" + "000" + bwb + "00001";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    //case OperandType.ConstantDirect:
                    //    il.len = 3; r2 = (int)constList[il.op2];
                    //    il.word1 = "1100011" + "000" + bwb + "00001";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool inop(InstructionLine il, char bwb='0')
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1000110" + s1 + bwb + s2 + "00";
                        break;
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1000110" + s1 + bwb + s2 + "10";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "1000110" + s1 +bwb+ "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "1000110" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelDirect:
                    case OperandType.VariableDirect:
                    case OperandType.ConstantDirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.LabelDirect) r2 = (int)lblList[il.op2];
                        if (il.op2t == OperandType.VariableDirect) r2 = (int)varList[il.op2];
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        il.word1 = "1000110" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        il.word1 = "1000110" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case OperandType.MemoryNamedDirect:
                    //case OperandType.MemoryNamedIndirect:
                    //    break;
                    default:
                        return false;
                }
            }
            //else if (il.op1t == OperandType.OperandType3)
            //{
            //    r1 = conv_int(il.op1);
            //    switch (il.op2t)
            //    {
            //        case OperandType.OperandType1:
            //            r2 = is_reg(il.op2);
            //            il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
            //            il.word1 = "1001100" + "0000" + s2 + "01";
            //            il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
            //            il.word2 = il.word2.Substring(il.word2.Length - 16);
            //            break;
            //        case OperandType.OperandType10:
            //        case OperandType.OperandType11:
            //            break;
            //    }
            //}
            //else if (il.op1t == OperandType.OperandType4)
            //{
            //    r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
            //    switch (il.op2t)
            //    {
            //        case OperandType.OperandType1:
            //            r2 = is_reg(il.op2);
            //            il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
            //            il.word1 = "1001100" + "0000" + s2 + "01";
            //            il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
            //            il.word2 = il.word2.Substring(il.word2.Length - 16);
            //            break;
            //        case OperandType.OperandType10:
            //        case OperandType.OperandType11:
            //            break;
            //        default:
            //            return false;
            //    }
            //}
            //else if (il.op1t == OperandType.OperandType12 || il.op1t == OperandType.OperandType13 | il.op1t == OperandType.OperandType14)
            //{
            //    if (il.op1t == OperandType.OperandType12) r1 = (int)llist[il.op1.Substring(1, il.op1.Length - 2)];
            //    if (il.op1t == OperandType.OperandType13) r1 = (int)vlist[il.op1.Substring(1, il.op1.Length - 2)];
            //    if (il.op1t == OperandType.OperandType14) r1 = (int)constlist[il.op1.Substring(1, il.op1.Length - 2)];
            //    switch (il.op2t)
            //    {
            //        case OperandType.OperandType1:
            //            r2 = is_reg(il.op2);
            //            il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
            //            il.word1 = "1001100" + "0000" + s2 + "01";
            //            il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
            //            il.word2 = il.word2.Substring(il.word2.Length - 16);
            //            break;
            //        case OperandType.OperandType10:
            //        case OperandType.OperandType11:
            //            break;
            //        default:
            //            return false;
            //    }
            //}
            else return false;
            return true;
        }

        private bool pmov(InstructionLine il, char bwb = '0')
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterAIndirect:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0101000" + s1 + bwb + s2 + "00";
                        break;
                    case OperandType.MemoryIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0101000" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.LabelIndirect:
                    case OperandType.VariableIndirect:
                    case OperandType.ConstantIndirect:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == OperandType.LabelIndirect) r2 = (int)lblList[s2];
                        if (il.op2t == OperandType.VariableIndirect) r2 = (int)varList[s2];
                        if (il.op2t == OperandType.ConstantIndirect) r2 = (int)constList[s2];
                        il.word1 = "0101000" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case OperandType.MemoryNamedIndirect:
                        il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0101000" + s1 + bwb + "000" + "01";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.RegisterAIndirect)
            {
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0101100" + s1 + bwb + s2 + "00";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryIndirect)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0101100" + "000" + bwb + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.LabelIndirect || il.op1t == OperandType.VariableIndirect | il.op1t == OperandType.ConstantIndirect)
            {
                if (il.op1t == OperandType.LabelIndirect) r1 = (int)lblList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.VariableIndirect) r1 = (int)varList[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == OperandType.ConstantIndirect) r1 = (int)constList[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0101100" + "000" + bwb + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == OperandType.MemoryNamedIndirect)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0101100" + "000" + bwb + s2 + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool pjumps(InstructionLine il, string op)  // two params second 0-15
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t == OperandType.Undefined || il.op2t == OperandType.Undefined) return false;
            if (il.op1t == OperandType.RegisterADirect)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + "1" + s2 + "00";
                        break;
                    case OperandType.MemoryDirect:
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        if (r2 > 7 || r2 < 0) { error = -7; return false; }
                        s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + "0" + s2 + "00";
                        break;
                    case OperandType.ConstantDirect:
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == OperandType.ConstantDirect) r2 = (int)constList[il.op2];
                        if (r2 > 7 || r2 < 0) { error = -7; return false; }
                        s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + "0" + s2 + "00";
                        break;
                    default:
                        return false;
                }
            }
            else
            if (il.op1t == OperandType.MemoryDirect)
            {
                il.len = 2; r1 = conv_int(il.op1);
                il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                il.word2 = il.word2.Substring(il.word2.Length - 16);
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + "0001" + s2 + "01";
                        break;
                    case OperandType.MemoryDirect:
                        r2 =  conv_int(il.op2);
                        if (r2 > 7 || r2 < 0) { error = -7; return false; }
                        s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + "0000" + s2 + "01";
                        break;
                    case OperandType.ConstantDirect:
                        r2 = (int)constList[il.op2];
                        if (r2 > 7 || r2 < 0) { error = -7; return false; }
                        s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + "0000" + s2 + "01";
                        break;
                    default:
                        return false;
                }
            }
            else
            if (il.op1t == OperandType.MemoryNamedDirect || il.op1t == OperandType.ConstantDirect || il.op1t == OperandType.LabelDirect || il.op1t == OperandType.VariableDirect )
            {
                il.len = 2;
                il.op1t = OperandType.MemoryNamedDirect;
                switch (il.op2t)
                {
                    case OperandType.RegisterADirect:
                        r2 = is_reg(il.op2);
                        s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + "0001" + s2 + "01";
                        break;
                    case OperandType.MemoryDirect:
                        r2 = conv_int(il.op2);
                        if (r2 > 7 || r2 < 0) { error = -7; return false; }
                        s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + "0000" + s2 + "01";
                        break;
                    case OperandType.ConstantDirect:
                        r2 = (int)constList[il.op2];
                        if (r2 > 7 || r2 < 0) { error = -7; return false; }
                        s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + "0000" + s2 + "01";
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private int conv_int(string s)
        {
            s.Replace(" ", "");
            int i = 0;
            if (((s[0] >= '0' && s[0] <= '9') || s[0] == '-')) //&& int.TryParse(s, out i)
            {
                try
                {
                    i = (int)new DataTable().Compute(s, null);
                    return i;
                }
                catch
                {
                }
            }
            if (s[0] == '$')
            {
                try { i = Convert.ToInt32(s.Substring(1), 16); }
                catch { return 0; }
                return i;
            }
            if (s[0] == '#')
            {
                try { i = Convert.ToInt32(s.Substring(1), 2); }
                catch { return 0; }
                return i;
            }
            else if (s.Length > 2 && s[0] == '\'' && s[2] == '\'')
            {
                i = (int)s[1];
                if (s.Length > 4 && s[3] == '+')
                {
                    i = i + Convert.ToInt32(s.Substring(4));
                }
                else if (s.Length > 4 && s[3] == '-')
                {
                    i = i - Convert.ToInt32(s.Substring(4));
                }
                return i;
            }
            else
            {
                string ss = String.Empty;
                int sp = 0; string t = String.Empty;
                if (s[sp] == '=') sp += 1;
                if (s[sp] == '@') { sp += 1; ss = address.ToString(); }
                while (sp < s.Length)
                    {
                        t = string.Empty;
                        while ((sp < s.Length) && (arith.IndexOf(s[sp]) != -1))
                        {
                            ss += s[sp];
                            sp = sp + 1;
                        };
                        while ((sp < s.Length) && (opers.IndexOf(s[sp]) == -1))
                        {
                            t += s[sp];
                            sp = sp + 1;
                        };
                        if (t != String.Empty)
                        {
                            if (lblList.ContainsKey(t)) { ss += lblList[t]; }
                            else
                            if (constList.ContainsKey(t)) { ss += constList[t]; }
                            else
                            if (varList.ContainsKey(t)) { ss += varList[t]; }
                            else ss += t;
                        }
                    }
                    i = (int)new DataTable().Compute(ss, null);
             }
             return i;
        }

        private bool Operation(InstructionLine il)
        {
            bool rn;
            switch (il.opcode)
            {
                case "NOP": il.len = 1; il.word1 = "0000000000000000";
                    break;
                case "MOV":
                    return mov(il);
                case "MOV.B":
                    return movb(il);
                case "ADD":
                    return add(il,'0'); 
                case "SUB":
                    return sub(il, '0'); 
                case "ADC":
                    return gen1(il, "0000101");
                case "ADC.B":
                    return gen1(il, "0000101", '1');
                case "MOVHL":
                    return gen1(il, "1001100");
                case "MOVLH":
                    return gen1(il, "1001101");
                case "MOVHH":
                    return gen1(il, "1001110");
                case "ADD.B":
                    return add(il, '1');
                case "SUB.B":
                    return sub(il, '1'); 
                case "ADDI":
                    return gen3(il, "1010100");
                case "SUBI":
                    return gen3(il, "1010011");
                case "SWAP":
                    return gen2(il, "0001000");
                case "CMP":
                    return cmpb(il, '0');
                case "CMP.B":
                    return cmpb(il, '1');
                case "AND":
                    return gen1(il, "0001111", '0');
                case "OR":
                    return gen1(il, "0010000", '0');
                case "XOR":
                    return gen1(il, "0010001", '0');
                case "NOT":
                    return gen2(il, "0010010", '0');
                case "AND.B":
                    return gen1(il, "0001111", '1');
                case "OR.B":
                    return gen1(il, "0010000", '1');
                case "XOR.B":
                    return gen1(il, "0010001", '1');
                case "NOT.B":
                    return gen2(il, "0010010", '1');
                case "SRA":
                    return gen3(il, "0011001");
                case "SLA":
                    return gen3(il, "0011010");
                case "SRL":
                    return gen3(il, "0011011");
                case "SLLL":
                    return gen4(il, "1001011");
                case "SRLL":
                    return gen4(il, "1011001");
                case "SLL":
                    return gen3(il, "0011100");
                case "ROL":
                    return gen3(il, "0110110");
                case "SRL.B":
                    return gen3(il, "1001111");
                case "SLL.B":
                    return gen3(il, "1010000");
                case "JMP":
                    return gen5(il, "0100101");
                case "JE":
                    return gen5(il, "0100110");
                case "JZ":
                    return gen5(il, "0100111",'1');
                case "JNE":
                    return gen5(il, "0100111");
                case "JNZ":
                    return gen5(il, "0100111");
                case "JO":
                    return gen5(il, "0101001",'1');
                case "JNO":
                    return gen5(il, "0101001");
                case "JC":
                case "JB":
                    return gen5(il, "0101011", '1');
                case "JL":
                    return gen5(il, "0110001");
                case "JNC":
                    return gen5(il, "0101011");
                case "JN":
                    return gen5(il, "0101101",'1');
                case "JP":
                    return gen5(il, "0101101");
                case "JBE":
                    return gen5(il, "0101110");
                case "JA":
                    return gen5(il, "0101111");
                case "JAE":
                    return gen5(il, "0011101");
                case "JR":
                    return gen6(il, "1110000");
                case "JRΕ":
                    return gen6(il, "1111001", '1');
                case "JRZ":
                    return gen6(il, "1111001", '1');
                case "JRNΕ":
                    return gen6(il, "1111001");
                case "JRNZ":
                    return gen6(il, "1111001");
                case "JRN":
                    return gen6(il, "1110010");
                case "JRO":
                    return gen6(il, "1110011");
                case "JRB":
                    return gen6(il, "1110100");
                case "JRC":
                    return gen6(il, "1110100");
                case "JSR":
                    return gen5(il, "0110101");
                case "JRSR":
                    return gen6(il, "1110110");
                case "RET": il.len = 1; il.word1 = "0110111000000000";
                    break;
                case "XCHG":
                    return gen4(il, "0011111");
                case "PUSH":
                    return push(il);
                case "POP":
                    return pop(il);
                case "INT":
                    return inter(il, "1000001");
                case "RETI": il.len = 1; il.word1 = "1000010000000000";
                    break;
                case "CLI": il.len = 1; il.word1 = "1000011000100000";
                    break;
                case "STI": il.len = 1; il.word1 = "1000011000000000";
                    break;
                case "OUT":
                    return outop(il);
                case "OUT.B":
                    return outop_b(il);
                case "IN":
                    return inop(il);
                case "IN.B":
                    return inop(il,'1');
                case "JRBE":
                    return gen6(il, "1110111");
                case "JRA":
                    return gen6(il, "1111010");
                case "INC":
                    return inc(il, '0');
                case "DEC":
                    return dec(il, '0');
                case "INC.B":
                    return inc(il, '1');
                case "DEC.B":
                    return dec(il, '1');
                case "JLE":
                    return gen5(il, "0111000");
                case "JG":
                    return gen5(il, "0111001");
                case "JGE":
                    return gen5(il, "0100011");
                case "JRLE":
                    return gen6(il, "1111000");
                case "JRL":
                    return gen6(il, "1111110");
                case "JRG":
                    return gen6(il, "1110101");
                case "JRGE":
                    return gen6(il, "1111101");
                case "BTST":
                    return gen3(il, "0010110");
                case "BSET":
                    return gen3(il, "0010111");
                case "BCLR":
                    return gen3(il, "0011000");
                case "SRSET":
                    return inter(il, "0100110",'1');
                case "SRCLR":
                    return inter(il, "0100110");
                case "MULU.B":
                    return gen1(il, "0001010", '1');
                case "MULU":
                    return gen1(il, "0001010", '0');
                case "MOVI":
                    return gen3(il, "0100000");
                case "MOVI.B":
                    return gen3(il, "0100010");
                case "CMPI":
                    return gen3(il, "1010010");
                case "CMPI.B":
                    return gen3(il, "0110000");
                case "CMPHL":
                    return gen1(il, "0110010");
                case "SETX":
                    return gen5(il, "0010011");
                case "JMPX":
                    return gen5(il, "0010100");
                case "JRX":
                    return gen6(il, "1111111");
                case "MOVX":
                    return gen2(il, "0010101");
                case "SETSP":
                    return gen5(il, "0001001");
                case "GETSP":
                    return gen2(il, "1000101");
                case "NEG":
                    return gen2(il, "1010101",'0');
                case "NEG.B":
                    return gen2(il, "1010101",'1');
                case "MOVR":
                    return movr(il, '0');
                case "GADR":
                    return movr(il, '0');
                case "MOVR.B":
                    return movr(il, '1');
                case "JXAB":
                    return gen1(il,"0110011",'1');
                case "JXAW":
                    return gen1(il,"0110011",'0');
                case "JRXAB":
                    return gen7(il, "1110001", '1');
                case "JRXAW":
                    return gen7(il, "1110001", '0');
                case "MTOI":
                    return gen4(il, "0111111", '1');
                case "MTOM":
                    return gen4(il, "0111111", '0');
                case "ITOI":
                    return gen4(il, "1101000", '1');
                case "ITOM":
                    return gen4(il, "1101000", '0');
                case "NTOI":
                    return gen1(il, "0101010", '1');
                case "NTOM":
                    return gen1(il, "0101010", '0');
                case "PUSHX": il.len = 1; il.word1 = "0111101000000000"; 
                    break;
                case "POPX": il.len = 1; il.word1 = "0111110000000000";
                    break;
                case "PRET":
                    il.len = 1; il.word1 = "1000010000100000";
                    break;
                case "PJSR":
                    il.op2t = parameter_type(il.op2);
                    return pjumps(il, "1000100");
                case "PJMP":
                    return pjumps(il, "0111100");
                case "SODP":
                    il.op1t = parameter_type(il.op1);
                    if (il.op1t == OperandType.RegisterADirect)
                    {
                        rn = gen2(il, "0000110");
                        if (rn) il.word1 = il.word1.Substring(0, 10) + "000000";
                    }
                    else { rn = inter(il, "0100100"); if (rn) il.word1 = il.word1.Substring(0, 10) + "1" + il.word1.Substring(11); }
                    return rn;
                case "SDP":
                    il.op1t = parameter_type(il.op1);
                    if (il.op1t == OperandType.RegisterADirect)
                    {
                        rn = gen2(il, "0000110");
                        if (rn) il.word1 = il.word1.Substring(0, 10) + "001000";
                    }
                    else rn = inter(il, "0100100");
                    return rn;
                case "SSP":
                    il.op1t = parameter_type(il.op1);
                    if (il.op1t == OperandType.RegisterADirect)
                    {
                        rn = gen2(il, "0000110");
                        if (rn) il.word1 = il.word1.Substring(0, 10) + "000100";
                    } else { rn = inter(il, "0000110"); if (rn) il.word1 = il.word1.Substring(0, 10) + "1" + il.word1.Substring(11); }
                    return rn;
                case "PMOV":
                    return pmov(il);
                case "PMOV.B":
                    return pmov(il,'1');
            }
            return true;
        }

        private bool add_oper(InstructionLine il)
        {
            bool res;
            il.opno = (int)instList[t];
            il.type = InstructionType.Operand; il.opcode = t;
            if (address % 2 == 1)
            {
                il.address = address + 1;
                LionAsmForm.errorbox.Text += " Warning operation at line: " + il.lno.ToString() + " automatically alinged to even address\r\n";
            }
            else il.address = address;
            if (il.opno > 0)
            {
                res = get_next_token2();
                if (res) il.op1 = t; else { error = -3; return false; }
                if (il.opno == 2)
                {
                    res = get_next_token2();
                    if (res) il.op2 = t; else { error = -3; return false; }
                }
            }
            res = Operation(il);
            if (!res) if (error >= 0) error = -4;
            if (address % 2 == 1) address = (ushort)(address + 1);
            address = (ushort)(address + 2 * il.len);
            return res;
        }

        private bool add_dir(InstructionLine il)
        {
            bool res; ushort w; int i;
            if (t == "ORG")
            {
                il.opcode = t;
                t = string.Empty;
                res = get_next_token();
                if (!res) { error = -1; return false; }
                if (t[0] == '$')
                {
                    try { i = Convert.ToInt32(t.Substring(1), 16); }
                    catch { return false; }
                }
                else if (t[0] == '#')
                {
                    try { i = Convert.ToInt32(t.Substring(1), 2); }
                    catch { return false; }
                }
                else
                {
                    if (!ushort.TryParse(t, out w)) { error = -2; return false; }
                }
                address = (ushort)conv_int(t); il.address = address;
                if (address > 65535) { error = -7; return false; }
            }
            else if (t == "PAGE")
            {
                il.opcode = t;
                il.type = InstructionType.Directive;
                t = string.Empty;
                res = get_next_token();
                if (!res) { error = -1; return false; }
                if (t[0] == '$')
                {
                    try { i = Convert.ToInt32(t.Substring(1), 16); }
                    catch { return false; }
                }
                else if (t[0] == '#')
                {
                    try { i = Convert.ToInt32(t.Substring(1), 2); }
                    catch { return false; }
                }
                else
                {
                    if (!ushort.TryParse(t, out w)) { error = -2; return false; }
                }
                address = (ushort)conv_int(t); il.address = address;
                if (address > 7) { error = -7; return false; }
                curpage = il.address;
                return res;
            }
            else if (t == "END")
            {
                il.opcode = t;
            }
            else if (t == "DS")
            {
                il.opcode = t;
                t = string.Empty;
                res = get_next_token();
                if (!res) { error = -1; return false; }
                if (t[0] == '$')
                {
                    try { i = Convert.ToInt32(t.Substring(1), 16); }
                    catch { return false; }
                }
                else if (t[0] == '#')
                {
                    try { i = Convert.ToInt32(t.Substring(1), 2); }
                    catch { return false; }
                }
                else
                {
                    if (!ushort.TryParse(t, out w)) { error = -2; return false; }
                }
                address += (ushort)conv_int(t);
                if (address > 65535) { error = -7; return false; }
                il.address = address;
            }
            else if (t == "DB" || t == "DW" || t == "TEXT" || t == "DA")
            {
                il.opcode = t;
                res = add_var_values(il);
                return res;
            }
            il.type = InstructionType.Directive;
            return true;
        }

        private bool is_num(string s)
        {
            int i;
            // int result = (int)new DataTable().Compute("1 + 2 * 7", null);
            s.Replace(" ","");
            if (s[0] == '$')
            {
                try { i = Convert.ToInt32(s.Substring(1), 16); }
                catch { return false; }
            }
            else if (s[0] == '#')
            {
                try { i = Convert.ToInt32(s.Substring(1), 2); }
                catch { return false; }
            }
            else if (s.Length > 2 && s[0] == '\'' && s[2] == '\'')
            {
                i = (int)s[1];
                if (s.Length > 4 && s[3] == '+')
                {
                    i = i + Convert.ToInt32(s.Substring(4));
                }
                else if (s.Length > 4 && s[3] == '-')
                {
                    i = i - Convert.ToInt32(s.Substring(4));
                }

                t = i.ToString();
            }
            else
            {
                //if (!int.TryParse(s, out i)) { error = -2; return false; }
                string ss=String.Empty;
                try
                {
                    int sp = 0;
                    if (s[sp] == '=') sp += 1;
                    if (s[sp] == '@') { sp += 1; ss = address.ToString(); }
                    while (sp < s.Length)
                    {
                        t = string.Empty;
                        while ((sp < s.Length) && (arith.IndexOf(s[sp]) != -1))
                        {
                            ss += s[sp];
                            sp = sp + 1;
                        };
                        while ((sp < s.Length) && (opers.IndexOf(s[sp]) == -1))
                        {
                            t += s[sp];
                            sp = sp + 1;
                        };
                        if (t != String.Empty) {
                            if (lblList.ContainsKey(t)) { ss += lblList[t]; }
                            else
                            if (constList.ContainsKey(t)) { ss += constList[t]; }
                            else
                            if (varList.ContainsKey(t)) { ss += varList[t]; }
                            else ss += t;
                        }
                    }
                    i = (int)new DataTable().Compute(ss, null);
                    t = i.ToString();
                }
                catch
                {
                    error = -2; return false;
                }
            }
            return true;
        }

        private bool add_var(InstructionLine il)
        {
            bool res; int v;
            il.variable = t; il.address = address;
            t = string.Empty;
            res = get_next_token();
            if (!res) { error = -1; return false; }
            if (t == "EQU")
            {
                il.opcode = t;
                il.type = InstructionType.Equate;
                t = string.Empty;
                res = get_next_token();
                if (!res) { error = -1; return false; }
                if (is_num(t))
                {
                    v = (ushort)conv_int(t);
                }
                else return false;
                if (varList.ContainsKey(il.variable) || lblList.ContainsKey(il.variable)) { error = -5; return false; }
                try
                {
                    constList.Add(il.variable, v);
                }
                catch
                {
                    error = -5;
                    return false;
                }
            }
            else if (t == "DB")
            {
                il.opcode = t;
                t = string.Empty; il.merge = false;
                if (lblList.ContainsKey(il.variable) || constList.ContainsKey(il.variable)) { error = -5; return false; }
                try { varList.Add(il.variable, (int)address); }
                catch
                {
                    error = -5;
                    return false;
                }
                il.values = new List<int>();
                if (address % 2 == 0)
                {
                    while (res = get_next_token2())
                    {
                        if (is_num(t))
                        {
                            v = (ushort)conv_int(t);
                        }
                        else return false;
                        v = v * 256;
                        il.len += 1;
                        address += 1;
                        t = string.Empty;
                        if (res = get_next_token2())
                        {
                            if (is_num(t))
                            {
                                v = v + (ushort)conv_int(t);
                                address += 1;
                                il.len += 1;
                            }
                            else return false;
                        }
                        else
                            il.merge = true;
                        il.values.Add((int)v);
                        t = string.Empty;
                    }

                }

                else
                {
                    v = 0;
                    while (res = get_next_token2())
                    {
                        if (is_num(t))
                        {
                            v = v + (ushort)conv_int(t);
                        }
                        else return false;
                        il.merge = true;
                        il.values.Add((int)v);
                        address += 1;
                        il.len += 1;
                        t = string.Empty;
                        if (res = get_next_token2())
                        {
                            if (is_num(t))
                            {
                                v = (ushort)conv_int(t) * 256;
                                address += 1;
                                il.len += 1;
                                il.merge = false;
                            }
                            else return false;
                        }
                        t = string.Empty;
                    }
                    if (il.len > 1 && il.len % 2 == 0)
                    {
                        il.values.Add((int)v);
                    }
                }
                il.type = InstructionType.DataByte;
            }
            else if (t == "TEXT")
            {
                il.opcode = t;
                t = string.Empty; il.merge = false;
                if (lblList.ContainsKey(il.variable) || constList.ContainsKey(il.variable)) { error = -5; return false; }
                try { varList.Add(il.variable, (int)address); }
                catch
                {
                    error = -5;
                    return false;
                }
                il.values = new List<int>();
                res = get_first_char();
                if (t != "\"" || !res) { error = -2; return false; }
                if (address % 2 == 0)
                {
                    while (res = get_next_char())
                    {
                        v = (ushort)t[0];
                        v = v * 256;
                        address += 1; il.len += 1;
                        t = string.Empty;
                        if (res = get_next_char())
                        {
                            v = v + (ushort)t[0];
                            address += 1; il.len += 1;
                        }
                        else il.merge = true;
                        il.values.Add((int)v);
                        t = string.Empty;
                    }

                }
                else
                {
                    v = 0;
                    while (res = get_next_char())
                    {
                        v = v + (ushort)t[0];
                        il.len += 1;
                        il.values.Add((int)v);
                        address += 1;
                        il.merge = true;
                        t = string.Empty;
                        if (res = get_next_char())
                        {
                            v = (ushort)t[0] * 256;
                            address += 1; il.len += 1;
                            t = string.Empty;
                            il.merge = false;
                        }
                        else break;
                    }
                    if (t != "\"") { error = -2; return false; }

                    if (il.len > 1 && il.len % 2 == 0)
                    {
                        il.values.Add((int)v);
                    }
                }
                il.type = InstructionType.DataByte;
            }
            else if (t == "DW")
            {
                if (address % 2 == 1)
                {
                    address += 1; il.address = address;
                    LionAsmForm.errorbox.Text += " Warning Label " + t + " automaticly alinged to even address\r\n";
                }
                il.opcode = t;
                t = string.Empty;
                il.values = new List<int>();
                if (lblList.ContainsKey(il.variable) || constList.ContainsKey(il.variable)) { error = -5; return false; }
                try
                {
                    varList.Add(il.variable, (int)address);
                }
                catch
                {
                    error = -5;
                    return false;
                }
                while (res = get_next_token2())
                {
                    if (is_num(t))
                    {
                        v = (ushort)conv_int(t);
                    }
                    else return false;
                    il.values.Add((int)v);
                    address += 2;
                    t = string.Empty;
                }
                il.type = InstructionType.DataWord;
            }
            else if (t == "DS")
            {
                int i;
                il.opcode = t;
                t = string.Empty;
                if (lblList.ContainsKey(il.variable) || constList.ContainsKey(il.variable)) { error = -5; return false; }
                try { varList.Add(il.variable, (int)address); }
                catch
                {
                    error = -5;
                    return false;
                }
                res = get_next_token();
                if (!res) { error = -1; return false; }
                if (t[0] == '$')
                {
                    try { i = Convert.ToInt32(t.Substring(1), 16); }
                    catch { return false; }
                }
                else if (t[0] == '#')
                {
                    try { i = Convert.ToInt32(t.Substring(1), 2); }
                    catch { return false; }
                }
                else
                {
                    ushort w;
                    if (!ushort.TryParse(t, out w)) { error = -2; return false; }
                }
                address += (ushort)conv_int(t);
                if (address > 65535) { error = -7; return false; }
                il.address = address;
            }
            else if (t == "DA")
            {
                if (address % 2 == 1)
                {
                    address += 1; il.address = address;
                    LionAsmForm.errorbox.Text += " Warning Label " + t + " automaticly alinged to even address\r\n";
                }

                if (lblList.ContainsKey(il.variable) || constList.ContainsKey(il.variable)) { error = -5; return false; }
                try { varList.Add(il.variable, (int)address); }
                catch
                {
                    error = -5;
                    return false;
                }
                il.opcode = t;
                t = string.Empty;
                res = get_next_token2();
                if (res)
                {
                    il.op1t = OperandType.MemoryNamedDirect;
                    il.op1 = t;
                    il.type = InstructionType.DataAddress;
                }
                else return false;
                address += 2;
                t = string.Empty;
            }
            else return false;
            return true;
        }

        private bool add_var_values(InstructionLine il)
        {
            bool res; int v;
            il.address = address;
            if (t == "EQU")
            {
                il.type = InstructionType.Equate;
                il.opcode = t;
                t = string.Empty;
                res = get_next_token();
                if (!res) { error = -1; return false; }
                if (is_num(t))
                {
                    v = (ushort)conv_int(t);
                }
                else return false;
                if (lblList.ContainsKey(il.variable) || varList.ContainsKey(il.variable)) { error = -5; return false; }
                try
                {
                    constList.Add(il.variable, v);
                }
                catch
                {
                    error = -5;
                    return false;
                }
            }
            else if (t == "DB")
            {
                il.opcode = t;
                t = string.Empty; il.merge = false;
                il.values = new List<int>();
                if (address % 2 == 0)
                {
                    while (res = get_next_token2())
                    {
                        if (is_num(t))
                        {
                            v = (ushort)conv_int(t);
                        }
                        else return false;
                        v = v * 256;
                        il.len += 1;
                        address += 1;
                        t = string.Empty;
                        if (res = get_next_token2())
                        {
                            if (is_num(t))
                            {
                                v = v + (ushort)conv_int(t);
                                address += 1;
                                il.len += 1;
                            }
                            else return false;
                        }
                        else
                            il.merge = true;
                        il.values.Add((int)v);
                        t = string.Empty;
                    }

                }
                else
                {
                    v = 0;
                    while (res = get_next_token2())
                    {
                        if (is_num(t))
                        {
                            v = v + (ushort)conv_int(t);
                        }
                        else return false;
                        il.merge = true;
                        il.values.Add((int)v);
                        address += 1;
                        il.len += 1;
                        t = string.Empty;
                        if (res = get_next_token2())
                        {
                            if (is_num(t))
                            {
                                v = (ushort)conv_int(t) * 256;
                                address += 1;
                                il.len += 1;
                                il.merge = false;
                            }
                            else return false;
                        }
                        t = string.Empty;
                    }
                    if (il.len > 1 && il.len % 2 == 0)
                    {
                        il.values.Add((int)v);
                    }
                }
                il.type = InstructionType.DataByte;
            }
            else if (t == "TEXT")
            {
                il.opcode = t;
                t = string.Empty; il.merge = false; 
                il.values = new List<int>();
                res = get_first_char();
                if (t != "\"" || !res) { error = -2; return false; }
                if (address % 2 == 0)
                {
                    while (res = get_next_char())
                    {
                        v = (ushort)t[0];
                        v = v * 256;
                        address += 1; il.len += 1;
                        t = string.Empty;
                        if (res = get_next_char())
                        {
                            v = v + (ushort)t[0];
                            address += 1; il.len += 1;
                        }
                        else il.merge = true;
                        il.values.Add((int)v);
                        t = string.Empty;
                    }

                }
                else
                {
                    v = 0;
                    while (res = get_next_char())
                    {
                        v = v + (ushort)t[0];
                        il.len += 1;
                        il.values.Add((int)v);
                        address += 1;
                        il.merge = true;
                        t = string.Empty;
                        if (res = get_next_char())
                        {
                            v = (ushort)t[0] * 256;
                            address += 1; il.len += 1;
                            t = string.Empty;
                            il.merge = false;
                        }
                        else break;
                    }
                    if (t != "\"") { error = -2; return false; }

                    if (il.len > 1 && il.len % 2 == 0)
                    {
                        il.values.Add((int)v);
                    }
                }
                il.type = InstructionType.DataByte;
            }
            else if (t == "DW")
            {
                if (address % 2 == 1)
                {
                    address += 1; il.address = address;
                    //L.errorbox.Text += " Warning Label " + t + " automaticly alinged to even address\r\n";
                }
                il.opcode = t;
                t = string.Empty;
                il.values = new List<int>();
                while (res = get_next_token2())
                {
                    if (is_num(t))
                    {
                        v = (ushort)conv_int(t);
                    }
                    else return false;
                    il.values.Add((int)v);
                    address += 2;
                    t = string.Empty;
                }
                il.type = InstructionType.DataWord;
            }
            else if (t == "DA")
            {
                il.opcode = t;
                if (address % 2 == 1)
                {
                    address += 1; il.address = address;
                    // L.errorbox.Text += " Warning Label " + t + " automaticly alinged to even address\r\n"; 
                }
                t = string.Empty;
                res = get_next_token2();
                if (res)
                {
                    il.op1t = OperandType.MemoryNamedDirect;
                    il.op1 = t;
                    il.type = InstructionType.DataAddress;
                }
                else return false;
                address += 2;
                t = string.Empty;
            }
            else return false;
            return true;
        }

        private bool parse_line()
        {
            bool res, ok;
            //int carry=0;
            InstructionLine il;
            t = string.Empty;
            ok = true;
            while ((res = get_next_token()) && ok)
            {
                il = new InstructionLine(l);
                il.page = curpage;
                if (t[t.Length - 1] == ':') ok = add_label(il);
                else if (instList.ContainsKey(t)) ok = add_oper(il);
                else if (dirList.ContainsKey(t)) ok = add_dir(il);
                else ok = add_var(il);
                if (ok)
                {
                    il.hexAddress = Convert.ToString(il.address, 16).ToUpper().PadLeft(4, '0');
                    il.hexValues = il.values != null ? il.values.Select(s => Convert.ToString(s, 16).ToUpper().PadLeft(4, '0')).ToList() : null;
                    if (il.type == InstructionType.DataByte && instListArr.Count > 0)
                    {
                        InstructionLine ill = (InstructionLine)instListArr[instListArr.Count - 1];
                        if (ill.merge)
                        {
                            int i = 0;
                            int ivc = il.values.Count;
                            int iivc = ill.values.Count;
                            foreach (int ii in il.values)
                            {
                                if (i == 0)
                                {
                                    ill.values[iivc - 1] = (int)ill.values[iivc - 1] + ii;
                                }
                                else
                                {
                                    ill.values.Add((int)ii);
                                }
                                i++;
                            }
                            ill.merge = !il.merge;
                            //if (i % 2 == 0) ill.merge = true; else ill.merge = false;
                        }
                        else instListArr.Add(il);
                    }
                    else instListArr.Add(il);
                }
                else { if (error >= 0) error = -6; return false; }
                t = string.Empty;
            }
            return ok;
        }

        private bool pass1()
        {
            bool res = true; l = 0; error = 0;
            LionAsmForm.errorbox.Text += "\r\n*** Pass1 - start \r\n";
            LionAsmForm.errorbox.Refresh();
            while (l < sourceLinesArr.Length && res)
            {
                p = 0;
                res = parse_line();
                l += 1;
            }
            if (error < 0)
            {
                LionAsmForm.errorbox.Text += "Error " + errList[-error] + " at line: " + Convert.ToString(l) + " \r\n";
                LionAsmForm.MarkLine(l-1, Color.Coral);
                return false;
            }
            LionAsmForm.errorbox.Text += "*** Pass1 - end \r\n";
            LionAsmForm.errorbox.Refresh();
            return true;
        }

        private bool pass2()
        {
            bool f = true; int i = 0, ad = 0;
            BinaryWriter bw = null;
            string temps = string.Empty;
            LionAsmForm.VHDL.Text = string.Empty;
            LionAsmForm.errorbox.Text += "*** Pass2 - start \r\n";
            LionAsmForm.errorbox.Refresh();
            for (int pg = 0; pg < 8; pg++)
            {
                pageListArr.Clear();
                foreach (InstructionLine il in instListArr)
                {
                    if (il.page == pg) { pageListArr.Add(il); }
                }
                if (pageListArr.Count() > 0)
                {
                    int ad2 = 0; i = 0; ad = 0;
                    string pgs = pg.ToString();
                    if (pgs == "0") pgs = String.Empty;
                    else temps += "\r\n" + "PAGE:" + pgs ;
                    //create the bin file
                    try
                    {
                        bw = new BinaryWriter(new FileStream(Path.GetFileNameWithoutExtension(LionAsmForm.fname) + pgs + ".bin", FileMode.Create));
                    }
                    catch (IOException e)
                    {
                        LionAsmForm.errorbox.Text += "Can't create Binary File! \r\n";
                        LionAsmForm.errorbox.Text += e.Message + "\r\n";
                    }

                    //create the mif file
                    StreamWriter sw = new StreamWriter(Path.GetFileNameWithoutExtension(LionAsmForm.fname) + pgs + ".mif", false, System.Text.Encoding.GetEncoding(1253));
                    sw.WriteLine("WIDTH=16;\nDEPTH=32767;\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\n\nCONTENT BEGIN\n\n");
                    int bad = 65535;
                    foreach (InstructionLine il1 in pageListArr)
                    {
                        if (il1.opcode == "ORG" && il1.address < bad) bad = il1.address;
                    }

                    foreach (InstructionLine il in pageListArr)
                    {
                        if (il.opcode == "ORG") temps += "\r\n";
                        if (il.op1t == OperandType.MemoryNamedDirect || il.op1t == OperandType.MemoryNamedIndirect)
                        {
                            string s = il.op1; f = false;
                            if (il.op1t == OperandType.MemoryNamedIndirect) s = s.Substring(1, s.Length - 2);
                            if (lblList.ContainsKey(s)) { i = (int)lblList[s]; f = true; }
                            if (constList.ContainsKey(s)) { i = (int)constList[s]; f = true; }
                            if (varList.ContainsKey(s)) { i = (int)varList[s]; f = true; }
                            if (f)
                            {
                                if (il.relative) { il.word2 = Convert.ToString((Int16)i - il.address - il.len * 2, 2).PadLeft(16, '0'); }
                                else il.word2 = Convert.ToString(i, 2).PadLeft(16, '0');
                                if (il.type == InstructionType.DataAddress)  //  DA command
                                {
                                    il.word1 = il.word2;
                                    il.word2 = string.Empty;
                                }
                            }
                            else
                            {
                                LionAsmForm.errorbox.Text += "Unknown identifier " + s + " at line: " + (il.lno + 1).ToString() + " \r\n";
                                LionAsmForm.MarkLine(il.lno, Color.Coral);
                                return false;
                            };
                        }

                        if (il.op2t == OperandType.MemoryNamedDirect || il.op2t == OperandType.MemoryNamedIndirect)
                        {
                            string s = il.op2; f = false;
                            if (il.op2t == OperandType.MemoryNamedIndirect) s = s.Substring(1, s.Length - 2);
                            if (lblList.ContainsKey(s)) { i = (int)lblList[s]; f = true; }
                            if (constList.ContainsKey(s)) { i = (int)constList[s]; f = true; }
                            if (varList.ContainsKey(s)) { i = (int)varList[s]; f = true; }
                            if (f)
                            {
                                if ((il.relative && il.op2t == OperandType.MemoryNamedDirect) || il.opcode == "MOVR" || il.opcode == "MOVR.B")
                                {
                                    if (il.len != 3) il.word2 = Convert.ToString((Int16)i - il.address - il.len * 2, 2).PadLeft(16, '0');
                                    else il.word3 = Convert.ToString((Int16)i - il.address - il.len * 2, 2).PadLeft(16, '0');
                                }
                                else
                                    if (il.len != 3) il.word2 = Convert.ToString(i, 2).PadLeft(16, '0');
                                else il.word3 = Convert.ToString(i, 2).PadLeft(16, '0');
                            }
                            else
                            {
                                LionAsmForm.errorbox.Text += "Unknown identifier " + s + " at line: " + (il.lno + 1).ToString() + " \r\n";
                                LionAsmForm.MarkLine(il.lno, Color.Coral);
                                return false;
                            };
                        }
                        if (il.word1 != string.Empty)
                        {
                            //if (il.address > 8191) ad = il.address - 8192; else
                            ad = il.address;
                            ad2 = il.address - bad;
                            temps += "tmp(" + Convert.ToString(ad / 2) + "):=\"" + il.word1 + "\"; ";
                            if (il.word2 != string.Empty) temps += "tmp(" + Convert.ToString(1 + ad / 2) + "):=\"" + il.word2 + "\";";
                            if (il.word3 != string.Empty) temps += " tmp(" + Convert.ToString(2 + ad / 2) + "):=\"" + il.word3 + "\";";
                            temps += " --" + il.opcode + " "+il.op1 +","+il.op2+" \r\n";
                            try
                            {
                                bw.Seek(ad2, 0);
                                bw.Write(Convert.ToByte(il.word1.Substring(0, 8), 2));
                                bw.Write(Convert.ToByte(il.word1.Substring(8, 8), 2));
                                sw.WriteLine(Convert.ToString(ad / 2) + " : " + il.word1 + ";");
                                if (il.word2 != string.Empty)
                                {
                                    bw.Write(Convert.ToByte(il.word2.Substring(0, 8), 2));
                                    bw.Write(Convert.ToByte(il.word2.Substring(8, 8), 2));
                                    sw.WriteLine(Convert.ToString(1 + ad / 2) + " : " + il.word2 + ";");
                                }
                                if (il.word3 != string.Empty)
                                {
                                    bw.Write(Convert.ToByte(il.word3.Substring(0, 8), 2));
                                    bw.Write(Convert.ToByte(il.word3.Substring(8, 8), 2));
                                    sw.WriteLine(Convert.ToString(2 + ad / 2) + " : " + il.word3 + ";");
                                }
                            }
                            catch (IOException e)
                            {
                                //LionAsmForm.errorbox.Text += "Can't write Binary File! \r\n";
                            }
                        }
                        if (il.type == InstructionType.DataWord || il.type == InstructionType.DataByte)
                        {
                            // if (il.address > 8191) ad = il.address - 8192; else
                            ad = il.address;
                            ad2 = il.address - bad;
                            int rr = 0;
                            foreach (int ii in il.values)
                            {
                                string s = Convert.ToString(ii, 2).PadLeft(16, '0');
                                s = s.Substring(s.Length - 16);
                                temps += "tmp(" + Convert.ToString(ad / 2) + "):=\"" + s + "\"; ";

                                try
                                {
                                    bw.Seek(ad2, 0);
                                    bw.Write(Convert.ToByte(s.Substring(0, 8), 2));
                                    bw.Write(Convert.ToByte(s.Substring(8, 8), 2));
                                    sw.WriteLine(Convert.ToString(ad / 2) + " : " + s + ";");
                                }
                                catch (IOException e)
                                {
                                }
                                ad += 2; ad2 += 2;
                                if (rr % 2 == 1) temps += " --" + il.opcode + "\r\n";
                                rr++;
                            }
                            if (rr % 2 == 1) temps += " --" + il.opcode + "\r\n";
                        }
                    }
                    LionAsmForm.VHDL.Text = temps;
                    if (bad == 0) LionAsmForm.BinSize.Text = ad2.ToString(); else LionAsmForm.BinSize.Text = (ad2 + 2).ToString();
                    bw.Close();
                    sw.WriteLine("END;\n");
                    sw.Close();
                }
            }
            return f;
        }

        public void parse()
        {
            bool res; 
            instListArr.Clear();
            constList.Clear();
            varList.Clear();
            lblList.Clear();

            //sourceLinesArr = (LionAsmForm.fftxtSource.Lines.Select(s => s.Substring(0, s.IndexOf(';') > -1 ? s.IndexOf(';') : s.Length).ToUpper().Trim()).ToArray()).Where(w => !string.IsNullOrEmpty(w)).ToArray(); //don't count comment lines, only instruction lines and the InstructionLine.lno's will NOT be consistent to source text lines

            sourceLinesArr = LionAsmForm.fftxtSource.Lines.Select(s => s.Substring(0, s.IndexOf(';') > -1 ? s.IndexOf(';') : s.Length).Trim()).ToArray(); // comment lines will be in the list as blanks and each InstructionLine.lno will be consistent to source text lines

            sourceLinesArr = sourceLinesArr.Select(s => s.Replace((char) 9,' ')).ToArray() ; // replace tabs with space

            sourceLinesArr = sourceLinesArr.Select(s => (s.ToUpper().IndexOf("TEXT ") > -1) ? s.Substring(0, s.ToUpper().IndexOf("TEXT")+4).ToUpper() + s.Substring(s.ToUpper().IndexOf("TEXT")+4, 
                             s.Length - s.ToUpper().IndexOf("TEXT")-4) : s.ToUpper()).ToArray(); // leave lines after TEXT lower case

            LionAsmForm.VHDL.Text = "-- Copy to LionSystem VHDL Rom or Ram init function\r\n";
            address = 32;
            error = 0; LionAsmForm.errorbox.Text = string.Empty;
            res = pass1();
#if DEBUG
            // save instListArr as xml for investigation
            if (instListArr.Count > 0)
                Utils.WriteObjectToXML(instListArr, "instListArr.xml");
#endif
            if (res)
            {
                if (LionAsmForm.Displv.Checked)
                {
                    DasmRecord symbols = new DasmRecord();

                    var orderedKeys1 = lblList.Keys.Cast<string>().OrderBy(c => c);
                    LionAsmForm.errorbox.Text += "\r\n*** Labels ***\r\n";
                    foreach (string k in orderedKeys1)
                    {
                        string hexval = Convert.ToString((int)lblList[k], 16).PadLeft(4, '0');
                        string binval = Convert.ToString((int)lblList[k], 2).PadLeft(16, '0');

                        LionAsmForm.errorbox.Text += k.PadRight(16) + ": $" + hexval
                            + "  #" + binval + "  " +
                            Convert.ToString((int)lblList[k], 10).PadLeft(5, '0') + " \r\n";

                        symbols.SymbolsList.Add(new DasmSymbol()
                        {
                            Name = k,
                            HexValue = hexval,
                            BinaryValue = binval,
                            DecimalValue = Convert.ToUInt32(lblList[k]),
                            isLabel = true
                        });
                    }
                    var orderedKeys2 = varList.Keys.Cast<string>().OrderBy(c => c);
                    LionAsmForm.errorbox.Text += "\r\n*** Variables ***\r\n";
                    foreach (string p in orderedKeys2)
                    {
                        string hexval = Convert.ToString((int)varList[p], 16).PadLeft(4, '0');
                        string binval = Convert.ToString((int)varList[p], 2).PadLeft(16, '0');

                        LionAsmForm.errorbox.Text += p.PadRight(16) + ": $" + hexval
                            + "  #" + binval + "  " +
                            Convert.ToString((int)varList[p], 10).PadLeft(5, '0') + " \r\n";

                        symbols.SymbolsList.Add(new DasmSymbol()
                        {
                            Name = p,
                            HexValue = hexval,
                            BinaryValue = binval,
                            DecimalValue = Convert.ToUInt32(varList[p])
                        });
                    }

                    // save symbols.SymbolsList as xml for disasm
                    if (symbols.SymbolsList.Count > 0)
                        Utils.WriteObjectToXML(symbols, LionAsmForm.fname + ".xml");

                }
                LionAsmForm.VHDL.Text = "-- Copy to LionSystem VHDL Rom or Ram init function\r\n";
                res = pass2();
                if (!res)
                {
                    LionAsmForm.errorbox.Text += "*** Pass 2 failed. ";
                }
                else { LionAsmForm.errorbox.Text += "*** Pass 2 end. "; }
            }
            else { LionAsmForm.errorbox.Text += "*** Pass 1 failed. \r\n"; }
            LionAsmForm.errorbox.SelectionStart = LionAsmForm.errorbox.TextLength;
            LionAsmForm.errorbox.ScrollToCaret();
        }

        public aparser(frmLionAsm LL)
        {
            LionAsmForm = LL;
            fill_clist();
            fill_ilist();
            fill_dlist();
        }

    }
}
