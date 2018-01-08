using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using System.Drawing;
using System.Data;

namespace WindowsFormsApplication1
{
    public sealed class iline
    {
        public int lno;
        public int type=-1;
        public string label="";
        public int address=0;
        public ushort len = 0;
        public string opcode="";
        public string op1="";
        public string op2="";
        public int op1t = 0, op2t = 0, opno = 0;
        public string word1="", word2="", word3="";
        public bool relative=false;
        public string variable="";
        public ArrayList values;
        public bool merge = false;

        public iline (int l)
        {
            this.lno = l;
        }
    }

    class aparser
    {

        public ArrayList instlist = new ArrayList();     // intermediate instruction list
        public Hashtable vlist = new Hashtable();       // variable list
        public Hashtable constlist = new Hashtable();  // constants list
        public Hashtable clist = new Hashtable();     // color list
        public Hashtable ilist = new Hashtable();    // instructions list
        public Hashtable dlist = new Hashtable();   // directive list
        public Hashtable llist = new Hashtable();  // label list
        public string[] errlist = { "Error 0", "<Bad syntax - missing value>", "<Bad Value>", "<Missing Parameter>",
                                      "<Bad parameter>","<Identifier already exists>", "<Unknown operation>", "<Number out of range>"  };
        private Lionasm L;
        private string[] clines = null;
        string delims = "\t\r\n, `"; //string delims2 = "\t\r\n,";
        string  t;
        string validchar = "ABCDEFGHIJKLMNOPQRSTVUWXYZ0123456789.():_-$#+-*/><=?\\%@'";
        string validchar2 = "ABCDEFGHIJKLMNOPQRSTVUWXYZ0123456789.():_-$#+-*/><=?\\%@' ";
        int p = 0, l = 0, error = 0;
        ushort address=32;
        iline lastline; 

        public void fill_clist()
        {
            clist.Add("NOP", Color.Blue);
            clist.Add("ADDI", Color.Blue);
            clist.Add("CMPI", Color.Blue);
            clist.Add("CMPI.B", Color.Blue);
            clist.Add("SUBI", Color.Blue);
            clist.Add("MOV", Color.Blue);
            clist.Add("ADD", Color.Blue);
            clist.Add("SUB", Color.Blue);
            clist.Add("ADC", Color.Blue);
            clist.Add("SWAP", Color.Blue);
            clist.Add("MUL", Color.Blue);
            clist.Add("CMP", Color.Blue);
            clist.Add("AND", Color.Blue);
            clist.Add("OR", Color.Blue);
            clist.Add("XOR", Color.Blue);
            clist.Add("NOT", Color.Blue);
            clist.Add("SRA", Color.Blue);
            clist.Add("SLA", Color.Blue);
            clist.Add("SRL", Color.Blue);
            clist.Add("SLL", Color.Blue);
            //clist.Add("ROR", Color.Blue);
            clist.Add("ROL", Color.Blue);
            clist.Add("JMP", Color.Blue);
            clist.Add("JZ", Color.Blue);
            clist.Add("JNZ", Color.Blue);
            clist.Add("JO", Color.Blue);
            clist.Add("JC", Color.Blue);
            clist.Add("JNC", Color.Blue);
            clist.Add("JN", Color.Blue);
            clist.Add("JP", Color.Blue);
            clist.Add("JBE", Color.Blue);
            clist.Add("JB", Color.Blue);
            clist.Add("JA", Color.Blue);
            clist.Add("JAE", Color.Blue);
            clist.Add("JR", Color.Blue);
            clist.Add("JRZ", Color.Blue);
            clist.Add("JRN", Color.Blue);
            clist.Add("JRO", Color.Blue);
            clist.Add("JRC", Color.Blue);
            clist.Add("JSR", Color.Blue);
            clist.Add("JRSR", Color.Blue);
            clist.Add("RET", Color.Blue);
            clist.Add("XCHG", Color.Blue);
            clist.Add("PUSH", Color.Blue);
            clist.Add("POP", Color.Blue);
            clist.Add("INT", Color.Blue);
            clist.Add("RETI", Color.Blue);
            clist.Add("CLI", Color.Blue);
            clist.Add("STI", Color.Blue);
            clist.Add("OUT", Color.Blue);
            clist.Add("IN", Color.Blue);
            clist.Add("INC", Color.Blue);
            clist.Add("DEC.B", Color.Blue);
            clist.Add("INC.B", Color.Blue);
            clist.Add("DEC", Color.Blue);
            clist.Add("JRBE", Color.Blue);
            clist.Add("JRA", Color.Blue);
            clist.Add("MOV.B", Color.Blue);
            clist.Add("MOVHL", Color.Blue);
            clist.Add("MOVLH", Color.Blue);
            clist.Add("MOVHH", Color.Blue);
            clist.Add("ADD.B", Color.Blue);
            clist.Add("ADC.B", Color.Blue);
            clist.Add("SUB.B", Color.Blue);
            clist.Add("MUL.B", Color.Blue);
            clist.Add("CMP.B", Color.Blue);
            clist.Add("AND.B", Color.Blue);
            clist.Add("OR.B", Color.Blue);
            clist.Add("XOR.B", Color.Blue);
            clist.Add("NOT.B", Color.Blue);
            //clist.Add("SRA.B", Color.Blue);
            //clist.Add("SLA.B", Color.Blue);
            clist.Add("SRL.B", Color.Blue);
            clist.Add("SLL.B", Color.Blue);
            clist.Add("ROR.B", Color.Blue);
            clist.Add("ROL.B", Color.Blue);
            clist.Add("JRA.B", Color.Blue);
            clist.Add("JLE", Color.Blue);
            clist.Add("JG", Color.Blue);
            clist.Add("JL", Color.Blue);
            clist.Add("JRLE", Color.Blue);
            clist.Add("JRG", Color.Blue);
            clist.Add("BTST", Color.Blue);
            clist.Add("BSET", Color.Blue);
            clist.Add("BCLR", Color.Blue);
            clist.Add("MULU", Color.Blue);
            clist.Add("MULU.B", Color.Blue);
            clist.Add("JRNZ", Color.Blue);
            clist.Add("MOVI", Color.Blue);
            clist.Add("MOVI.B", Color.Blue);
            clist.Add("SETX", Color.Blue);
            clist.Add("JMPX", Color.Blue);
            clist.Add("PUSHX", Color.Blue);
            clist.Add("POPX", Color.Blue);
            clist.Add("MOVX", Color.Blue);
            clist.Add("SETSP", Color.Blue);
            clist.Add("GETSP", Color.Blue);
            //clist.Add("MOVMI", Color.Blue);
            //clist.Add("CMPHL", Color.Blue);
            clist.Add("MOVR", Color.Blue);
            clist.Add("GADR", Color.Blue);
            clist.Add("MOVR.B", Color.Blue);
            clist.Add("END", Color.Magenta );
            clist.Add("ORG", Color.Magenta);
            clist.Add("DB", Color.Magenta);
            clist.Add("DW", Color.Magenta);
            clist.Add("DS", Color.Magenta);
            clist.Add("EQU", Color.Magenta);
            clist.Add("TEXT", Color.Magenta);
            clist.Add("DA", Color.Magenta);
        }

        public void fill_ilist()
        {
            ilist.Add("NOP", 0);
            ilist.Add("MOV", 2);
            ilist.Add("ADD", 2);
            ilist.Add("SUB", 2);
            ilist.Add("ADC", 2);
            ilist.Add("SWAP", 1);
            ilist.Add("CMP", 2);
            ilist.Add("AND", 2);
            ilist.Add("OR", 2);
            ilist.Add("XOR", 2);
            ilist.Add("NOT", 1);
            ilist.Add("SRA", 2);
            ilist.Add("SLA", 2);
            ilist.Add("SRL", 2);
            ilist.Add("SLL", 2);
            //ilist.Add("ROR", 2);
            ilist.Add("ROL", 2);
            ilist.Add("JMP", 1);
            ilist.Add("JZ", 1);
            ilist.Add("JNZ", 1);
            ilist.Add("JO", 1);
            ilist.Add("JC", 1);
            ilist.Add("JNC", 1);
            ilist.Add("JN", 1);
            ilist.Add("JP", 1);
            ilist.Add("JBE", 1);
            ilist.Add("JB", 1);
            ilist.Add("JA", 1);
            ilist.Add("JAE", 1);
            ilist.Add("JR", 1);
            ilist.Add("JRZ", 1);
            ilist.Add("JRN", 1);
            ilist.Add("JRO", 1);
            ilist.Add("JRC", 1);
            ilist.Add("JSR", 1);
            ilist.Add("JRSR", 1);
            ilist.Add("RET", 0);
            ilist.Add("XCHG", 2);
            ilist.Add("PUSH", 1);
            ilist.Add("POP", 1);
            ilist.Add("INT", 1);
            ilist.Add("RETI", 0);
            ilist.Add("CLI", 0);
            ilist.Add("STI", 0);
            ilist.Add("OUT", 2);
            ilist.Add("IN", 2);
            ilist.Add("INC", 1);
            ilist.Add("INC.B", 1);
            ilist.Add("DEC", 1);
            ilist.Add("DEC.B", 1);
            ilist.Add("JRBE", 1);
            ilist.Add("JRA", 1);
            ilist.Add("MOV.B", 2);
            ilist.Add("MOVHL", 2);
            ilist.Add("MOVLH", 2);
            ilist.Add("MOVHH", 2);
            ilist.Add("ADD.B", 2);
            ilist.Add("ADC.B", 2);
            ilist.Add("SUB.B", 2);
            //ilist.Add("MUL.B", 2);
            ilist.Add("CMP.B", 2);
            ilist.Add("AND.B", 2);
            ilist.Add("OR.B", 2);
            ilist.Add("XOR.B", 2);
            ilist.Add("NOT.B", 1);
            //ilist.Add("SRA.B", 2);
            //ilist.Add("SLA.B", 2);
            ilist.Add("SRL.B", 2);
            ilist.Add("SLL.B", 2);
            //ilist.Add("ROR.B", 2);
            //ilist.Add("ROL.B", 2);
            ilist.Add("JRA.B", 1);
            ilist.Add("JLE", 1);
            ilist.Add("JL", 1);
            ilist.Add("JG", 1);
            ilist.Add("JRLE",1);
            ilist.Add("JRG", 1);
            ilist.Add("BTST", 2);
            ilist.Add("BSET", 2);
            ilist.Add("BCLR", 2);
            ilist.Add("MULU", 2);
            ilist.Add("MULU.B", 2);
            ilist.Add("JRNZ", 1);
            ilist.Add("MOVI", 2);
            ilist.Add("MOVI.B", 2);
            ilist.Add("ADDI", 2);
            ilist.Add("CMPI", 2);
            ilist.Add("CMPI.B", 2);
            ilist.Add("SUBI", 2);
            ilist.Add("SETX", 1);
            ilist.Add("JMPX", 1);
            ilist.Add("PUSHX", 0);
            ilist.Add("MOVX", 1);
            ilist.Add("POPX", 0);
            ilist.Add("SETSP", 1);
            ilist.Add("GETSP", 1);
            //ilist.Add("CMPHL", 1);
            ilist.Add("MOVR", 2);
            ilist.Add("MOVR.B", 2);
            ilist.Add("GADR", 2);
            //ilist.Add("MOVMI", 2);
        }

        public void fill_dlist()
        {
            dlist.Add("END", Color.Green);
            dlist.Add("ORG", Color.Green);
            dlist.Add("DW", Color.Green);
            dlist.Add("DB", Color.Green);
            dlist.Add("DS", Color.Green);
            dlist.Add("TEXT", Color.Green);
            dlist.Add("DA", Color.Green);
        }

        public void fill_errlist()
        {
            
        }

        private bool get_next_token()
        {
            t = "";
            while ((p < clines[l].Length) && (delims.IndexOf(clines[l][p]) != -1))
            {
                p=p+1;
            };
            while ((p < clines[l].Length) &&  (validchar.IndexOf(clines[l][p]) != -1) )
            {
                t = t + clines[l][p];
                p = p + 1;
            };
            if (t.Length<=0) return false; else return true;
        }

        private bool get_next_token2()
        {
            t = "";
            while ((p < clines[l].Length) && (delims.IndexOf(clines[l][p]) != -1))
            {
                p = p + 1;
            };
            while ((p < clines[l].Length) && (validchar2.IndexOf(clines[l][p]) != -1))
            {
                if (clines[l][p]!=' ') t = t + clines[l][p];
                p = p + 1;
            };
            if (t.Length <= 0) return false; else return true;
        }

        private bool get_next_char()
        {
            t = "";
            if (p < clines[l].Length)
            {
                t =t + clines[l][p];
                p = p + 1;
            };
            if (t.Length == 0 || t == "\"" ) return false; else return true;
        }

        private bool get_first_char()
        {
            t = "";
            while ((p < clines[l].Length) && (delims.IndexOf(clines[l][p]) != -1))
            {
                p = p + 1;
            };
            if (p < clines[l].Length)
            {
                t = t + clines[l][p];
                p = p + 1;
            };
            if (t.Length <= 0) return false; else return true;
        }

        private bool add_label(iline il)
        {
            il.type = 2; 
            il.label = t.Substring(0,t.Length-1);
            if (address % 2 == 1) { il.address = address + 1;
            L.errorbox.Text += " Warning Label " + t + " automaticly alinged to even address\r\n";
            } else il.address = address;
            try
            {
                llist.Add(il.label, (int)address);
            }
            catch
                {
                    error = -5;
                    return false;
                }
            return true;
        }

        private int parameter_type(string s)
        {
            int i;
            if (s == "") return -1;
            if (s.Length==2 && s[0] == 'A' && (s[1] >= '0' && s[1] < '8'))
            {
                return 1;
            }
            if (s.Length == 2 && s[0] == 'B' && (s[1] >= '0' && s[1] < '8'))
            {
                return 9;
            }
            if (s.Length==4 &&  s[0] == '(' && s[1] == 'A' && (s[2] >= '0' && s[2] < '8') && s[3] == ')')
            {
                return 2;
            }
            if (((s[0] >= '0' && s[0] <= '9') || s[0]=='-' || s[0]=='\'') && is_num(s))
            {
                return 3;
            }
            if (s[0] == '$'  )
            {
                try { Convert.ToInt32(s.Substring(1, s.Length - 1), 16); }
                catch { return -1;  }
                return 3;
            }
            if (s[0] == '#')
            {
                try { Convert.ToInt32(s.Substring(1, s.Length - 1), 2); }
                catch { return -1; }
                return 3;
            }
            if (s[0] == '(')
            {
                if (((s[1] >= '0' && s[1] <= '9') || s[1] == '-') && int.TryParse(s.Substring(1, s.Length - 2), out i))
                {
                    return 4;
                }
                if (s[1] == '$')
                {
                    try { Convert.ToInt32(s.Substring(2, s.Length - 3), 16); }
                    catch { return -1; }
                    return 4;
                }
                if (s[1] == '#')
                {
                    try { Convert.ToInt32(s.Substring(2, s.Length - 3), 2); }
                    catch { return -1; }
                    return 4;
                }
            }

            if (s.Length > 1 && s[0] == 'P' && s[1] == 'C' && s.Length == 2)
            {
                return 5;
            }
            if (s.Length > 1 && s[0] == 'S' && s[1] == 'R' && s.Length == 2)
            {
                return 15;
            }
            if ((s[0] >= 'A' && s[0] <= 'Z') || (s[0] =='_'))
            {
                if (llist.ContainsKey(s)) return 6;
                if (constlist.ContainsKey(s)) return 8;
                if (vlist.ContainsKey(s)) return 7;
                return 10;
            }
            if (s.Length > 1 && s[0] == '(' && ((s[1] >= 'A' && s[1] <= 'Z') || (s[1] == '_')))
            {
                if (llist.ContainsKey(s.Substring(1,s.Length-2))) return 12;
                if (constlist.ContainsKey(s.Substring(1, s.Length - 2))) return 14;
                if (vlist.ContainsKey(s.Substring(1, s.Length - 2))) return 13;
                return 11;
            }
            
            return -1;
        }

        private int is_reg(string s)
        {
            if ((s[0] == 'A') && (s[1] >= '0' && s[1] < '8')) 
            {
                return Convert.ToInt16(s[1]-'0');
            }
            return -1;
        }

        private int is_reg_ref(string s)
        {
            if (s[0] == '(' && s[1] == 'A' &&  (s[2] >= '0' && s[2] < '8') && s[3]==')' )
            {
                return Convert.ToInt16(s[2]-'0');
            }
            return -1;
        }

        // 1 Reg   2  (Reg)  3 num  4 (num)  5 PC  6 LABEL  7 variable  8 constant  9 Breg XXX
        // 10 To be filled  11 (TBF)  12 (L)  13 (V)  14 (C)  15 SR  16 SP 

        private bool mov(iline il)
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t < 0 || il.op2t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "0" + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "0" + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 =conv_int (il.op2);
                        il.word1 = "0000001" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 4:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0000001" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 5:
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = address;
                        il.word1 = "0111010" + s1 + "0000" + "00";
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "0000001" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case 9:
                    //    r2 = is_reg(il.op2);
                    //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "0111001" + s1 + "0" + s2 + "00";
                    //    break;
                    case 12:
                    case 13:
                    case 14:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == 12) r2 = (int)llist[s2];
                        if (il.op2t == 13) r2 = (int)vlist[s2];
                        if (il.op2t == 14) r2 = (int)constlist[s2];
                        il.word1 = "0000001" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "0000" + "01";
                        break;
                    case 11: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000001" + s1 + "0000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 2)
            {
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000010" + s1 + "0" + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000010" + s1 + "0" + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0000010" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 4:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0000010" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "0000010" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 12:
                    case 13:
                    case 14:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == 12) r2 = (int)llist[s2];
                        if (il.op2t == 13) r2 = (int)vlist[s2];
                        if (il.op2t == 14) r2 = (int)constlist[s2];
                        il.word1 = "0000010" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000010" + s1 + "0000" + "01";
                        break;
                    case 11: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000010" + s1 + "0000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 4)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001001" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 3:
                        il.len = 3;  r2 = conv_int(il.op2);
                        il.word1 = "1100000" + "0000000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 3; 
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "1100000" + "0000000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    //case 12:
                    //case 13:
                    //case 14:
                    //    il.len = 3; address += 2; r2 = conv_int(il.op2);
                    //    if (il.op2t == 6) r1 = (int)llist[il.op1];
                    //    if (il.op2t == 7) r1 = (int)vlist[il.op1];
                    //    if (il.op2t == 8) r1 = (int)constlist[il.op1];
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    //case 10: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001001" + "0000" + s2 + "01";
                    //    break;
                    //case 11: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001001" + "0000" + s2 + "01";
                    //    break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 12 || il.op1t == 13 | il.op1t == 14)
            {
                if (il.op1t == 12) r1 = (int)llist[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == 13) r1 = (int)vlist[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == 14) r1 = (int)constlist[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001001" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 3:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100000" + "0000000" + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 3;
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
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
            else if (il.op1t == 11)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001001" + "0000" + s2 + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 3:
                        il.len = 3;  r2 = conv_int(il.op2);
                        il.word1 = "1100000" + "0000000" + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 3;
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "1100000" + "0000000" + "01";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 10: il.len = 3;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1100000" + s1 + "0000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool movb(iline il)
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t < 0 || il.op2t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000110" + s1 + "1" + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000110" + s1 + "1" + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0000110" + s1 + "1000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 4:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0000110" + s1 + "1000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "0000110" + s1 + "1000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 12:
                    case 13:
                    case 14:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == 12) r2 = (int)llist[s2];
                        if (il.op2t == 13) r2 = (int)vlist[s2];
                        if (il.op2t == 14) r2 = (int)constlist[s2];
                        il.word1 = "0000110" + s1 + "1000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000110" + s1 + "1000" + "01";
                        break;
                    case 11: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0000110" + s1 + "1000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            // 1 Reg   2  (Reg)  3 num  4 (num)  5 PC  6 LABEL  7 variable  8 constant  9 Breg XXX
            // 10 To be filled  11 (TBF)  12 (L)  13 (V)  14 (C)  15 SR  16 SP 
            else if (il.op1t == 2)
            {
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001100" + s1 + "1" + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001100" + s1 + "1" + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0001100" + s1 + "1000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 4:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0001100" + s1 + "1000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "0001100" + s1 + "1000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 12:
                    case 13:
                    case 14:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == 12) r2 = (int)llist[s2];
                        if (il.op2t == 13) r2 = (int)vlist[s2];
                        if (il.op2t == 14) r2 = (int)constlist[s2];
                        il.word1 = "0001100" + s1 + "1000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0001100" + s1 + "1000" + "01";
                        break;
                    case 11: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0001100" + s1 + "1000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 4)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001010" + "0001" + s2 + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 3:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100001" + "0001000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 3;
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "1100001" + "0001000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    //case 10: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001010" + "0000" + s2 + "11";
                    //    break;
                    //case 11: il.len = 2;
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
            else if (il.op1t == 12 || il.op1t == 13 | il.op1t == 14)
            {
                if (il.op1t == 12) r1 = (int)llist[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == 13) r1 = (int)vlist[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == 14) r1 = (int)constlist[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001010" + "0001" + s2 + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 3:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100001" + "0001000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 3;
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "1100001" + "0001000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 10:
                    case 11:
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 11)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1001010" + "0001" + s2 + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 3:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100001" + "0001000" + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 3;
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
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

        private bool cmpb(iline il, char bwb)
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t < 0 || il.op2t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001110" + s1 + bwb + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001110" + s1 + bwb + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0001110" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 4:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0001110" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "0001110" + s1 + bwb +"000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 12:
                    case 13:
                    case 14:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == 12) r2 = (int)llist[s2];
                        if (il.op2t == 13) r2 = (int)vlist[s2];
                        if (il.op2t == 14) r2 = (int)constlist[s2];
                        il.word1 = "0001110" + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0001110" + s1 + bwb + "000" + "01";
                        break;
                    case 11: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0001110" + s1 + bwb + "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 2)
            {
                // 1 Reg   2  (Reg)  3 num  4 (num)  5 PC  6 LABEL  7 variable  8 constant  9 Breg XXX
                // 10 To be filled  11 (TBF)  12 (L)  13 (V)  14 (C)  15 SR  16 SP 
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0100001" + s1 + bwb + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0100001" + s1 + bwb + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0100001" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case 4:
                    //    il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                    //    il.word1 = "0100001" + s1 + bwb + "000" + "11";
                    //    il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "0100001" + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case 12:
                    //case 13:
                    //case 14:
                    //    il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    //    s2 = il.op2.Substring(1, il.op2.Length - 2);
                    //    if (il.op2t == 12) r2 = (int)llist[s2];
                    //    if (il.op2t == 13) r2 = (int)vlist[s2];
                    //    if (il.op2t == 14) r2 = (int)constlist[s2];
                    //    il.word1 = "0100001" + s1 + bwb + "000" + "11";
                    //    il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    case 10: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0100001" + s1 + bwb + "000" + "01";
                        break;
                    case 11: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "0100001" + s1 + bwb + "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 4)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001101" + "000" + bwb + s2 + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 3:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 3;
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    //case 10: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001010" + "0000" + s2 + "11";
                    //    break;
                    //case 11: il.len = 2;
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
            else if (il.op1t == 12 || il.op1t == 13 | il.op1t == 14)
            {
                if (il.op1t == 12) r1 = (int)llist[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == 13) r1 = (int)vlist[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == 14) r1 = (int)constlist[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001101" + "000" + bwb + s2 + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 3:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 3;
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 10:
                    case 11:
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 11)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0001101" + "000" + bwb + s2 + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 3:
                        il.len = 3; r2 = conv_int(il.op2);
                        il.word1 = "1100010" + "000" + bwb + "000" + "11";
                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
                        il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word3 = il.word3.Substring(il.word3.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 3;
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
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

        private bool gen1(iline il, string op)  // two params first a register
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t < 0 || il.op2t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + "0" + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + "0" + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = op + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 4:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = op + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = op + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 12:
                    case 13:
                    case 14:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == 12) r2 = (int)llist[s2];
                        if (il.op2t == 13) r2 = (int)vlist[s2];
                        if (il.op2t == 14) r2 = (int)constlist[s2];
                        il.word1 = op + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + "0000" + "01";
                        break;
                    case 11: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + "0000" + "11";
                        break;
                    default:
                        return false;
                }
            } 
            //else
            //if (il.op1t == 9 && op == "0001101")
            //{
            //    if (op == "0001101") op = "1000101";
            //    r1 = is_reg(il.op1);
            //    switch (il.op2t)
            //    {
            //        case 1:
            //            r2 = is_reg(il.op2);
            //            il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
            //            il.word1 = op + s1 + "0" + s2 + "00";
            //            break;
            //        case 2:
            //            r2 = is_reg_ref(il.op2);
            //            il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
            //            il.word1 = op + s1 + "0" + s2 + "10";
            //            break;
            //        case 3:
            //            il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
            //            il.word1 = op + s1 + "0000" + "01";
            //            il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
            //            il.word2 = il.word2.Substring(il.word2.Length - 16);
            //            break;
            //        case 4:
            //            il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
            //            il.word1 = op + s1 + "0000" + "11";
            //            il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
            //            il.word2 = il.word2.Substring(il.word2.Length - 16);
            //            break;
            //        case 6:
            //        case 7:
            //        case 8:
            //            il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //            if (il.op2t == 6) r2 = (int)llist[il.op2];
            //            if (il.op2t == 7) r2 = (int)vlist[il.op2];
            //            if (il.op2t == 8) r2 = (int)constlist[il.op2];
            //            il.word1 = op + s1 + "0000" + "01";
            //            il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
            //            il.word2 = il.word2.Substring(il.word2.Length - 16);
            //            break;
            //        case 12:
            //        case 13:
            //        case 14:
            //            il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //            s2 = il.op2.Substring(1, il.op2.Length - 2);
            //            if (il.op2t == 12) r2 = (int)llist[s2];
            //            if (il.op2t == 13) r2 = (int)vlist[s2];
            //            if (il.op2t == 14) r2 = (int)constlist[s2];
            //            il.word1 = op + s1 + "0000" + "11";
            //            il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
            //            il.word2 = il.word2.Substring(il.word2.Length - 16);
            //            break;
            //        case 10: il.len = 2;
            //            s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //            il.word1 = op + s1 + "0000" + "01";
            //            break;
            //        case 11: il.len = 2;
            //            s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //            il.word1 = op + s1 + "0000" + "11";
            //            break;
            //        default:
            //            return false;
            //    }
            //}
            else return false;
            return true;
        }

        private bool gen1(iline il, string op, char bwb)  // two params first a register
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t < 0 || il.op2t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + bwb + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + bwb + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = op + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 4:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = op + s1 + bwb+ "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = op + s1 + bwb + "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 12:
                    case 13:
                    case 14:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == 12) r2 = (int)llist[s2];
                        if (il.op2t == 13) r2 = (int)vlist[s2];
                        if (il.op2t == 14) r2 = (int)constlist[s2];
                        il.word1 = op + s1 + bwb + "000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + bwb + "000" + "01";
                        break;
                    case 11: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + bwb + "000" + "11";
                        break;
                    default:
                        return false;
                }
            }
            //else
            //    if (il.op1t == 9 && op == "0001101")
            //    {
            //        if (op == "0001101") op = "1000101";
            //        r1 = is_reg(il.op1);
            //        switch (il.op2t)
            //        {
            //            case 1:
            //                r2 = is_reg(il.op2);
            //                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
            //                il.word1 = op + s1 + "0" + s2 + "00";
            //                break;
            //            case 2:
            //                r2 = is_reg_ref(il.op2);
            //                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
            //                il.word1 = op + s1 + "0" + s2 + "10";
            //                break;
            //            case 3:
            //                il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
            //                il.word1 = op + s1 + "0000" + "01";
            //                il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
            //                il.word2 = il.word2.Substring(il.word2.Length - 16);
            //                break;
            //            case 4:
            //                il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
            //                il.word1 = op + s1 + "0000" + "11";
            //                il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
            //                il.word2 = il.word2.Substring(il.word2.Length - 16);
            //                break;
            //            case 6:
            //            case 7:
            //            case 8:
            //                il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //                if (il.op2t == 6) r2 = (int)llist[il.op2];
            //                if (il.op2t == 7) r2 = (int)vlist[il.op2];
            //                if (il.op2t == 8) r2 = (int)constlist[il.op2];
            //                il.word1 = op + s1 + "0000" + "01";
            //                il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
            //                il.word2 = il.word2.Substring(il.word2.Length - 16);
            //                break;
            //            case 12:
            //            case 13:
            //            case 14:
            //                il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //                s2 = il.op2.Substring(1, il.op2.Length - 2);
            //                if (il.op2t == 12) r2 = (int)llist[s2];
            //                if (il.op2t == 13) r2 = (int)vlist[s2];
            //                if (il.op2t == 14) r2 = (int)constlist[s2];
            //                il.word1 = op + s1 + "0000" + "11";
            //                il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
            //                il.word2 = il.word2.Substring(il.word2.Length - 16);
            //                break;
            //            case 10: il.len = 2;
            //                s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //                il.word1 = op + s1 + "0000" + "01";
            //                break;
            //            case 11: il.len = 2;
            //                s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //                il.word1 = op + s1 + "0000" + "11";
            //                break;
            //            default:
            //                return false;
            //        }
            //    }
                else return false;
            return true;
        }

        private bool gen2(iline il, string op)  // one param always a register
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t < 0 ) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); 
                il.word1 = op + s1 + "000000";
            } 
            //else
            //    if (il.op1t == 9 && (op == "1000111" || op == "1001000"))
            //{
            //    op2 = op;
            //    if (op == "1000111") op2 = "1100000";
            //    if (op == "1001000") op2 = "1100001";
            //    r1 = is_reg(il.op1);
            //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //    il.word1 = op2 + s1 + "000000";
            //}
            else return false;
            return true;
        }

        private bool gen2(iline il, string op, char bwb)  // one param always a register bwb
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                il.word1 = op + s1 + bwb+ "00000";
            }
            //else
            //    if (il.op1t == 9 && (op == "1000111" || op == "1001000"))
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

        private bool gen3(iline il, string op)  // two params second 0-15
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t < 0 || il.op2t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case 3:
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        if (r2 > 15 || r2 < 0) { error = -7; return false; }
                        if (il.opcode == "ROR") r2 = 16 - r2;
                        s2 = Convert.ToString(r2, 2).PadLeft(4, '0');
                        il.word1 = op + s1 + s2 + "00";
                        break;
                    case 8:
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        if (r2 > 15 || r2 < 0) { error = -7; return false; }
                        if (il.opcode == "ROR") r2 = 16 - r2;
                        s2 = Convert.ToString(r2, 2).PadLeft(4, '0');
                        il.word1 = op + s1 + s2 + "00";
                        break;
                    default:
                        return false;
                }
            } 
            else
                if (il.op1t == 4)
                {
                    r1 = is_reg(il.op1);
                    switch (il.op2t)
                    {
                        case 3:
                            il.len = 2; s1 = Convert.ToString(0, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                            r1 =  conv_int(il.op1.Substring(1, il.op1.Length - 2));
                            if (r2 > 15 || r2 < 0) { error = -7; return false; }
                            if (il.opcode == "ROR") r2 = 16 - r2;
                            s2 = Convert.ToString(r2, 2).PadLeft(4, '0');
                            il.word1 = op + s1 + s2 + "11";
                            il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                            il.word2 = il.word2.Substring(il.word2.Length - 16);
                            break;
                        default:
                            return false;
                    }
                }
                else
                    if (il.op1t == 11)
                    {
                        r1 = is_reg(il.op1);
                        switch (il.op2t)
                        {
                            case 3:
                                il.len = 2; s1 = Convert.ToString(0, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                                if (r2 > 15 || r2 < 0) { error = -7; return false; }
                                if (il.opcode=="ROR")  r2=16-r2; 
                                s2 = Convert.ToString(r2, 2).PadLeft(4, '0');
                                il.word1 = op + s1 + s2 + "11";
                                //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                                //il.word2 = il.word2.Substring(il.word2.Length - 16);
                                break;
                            default:
                                return false;
                        }
                    } 
            //else if (il.op1t == 9)
            //{
            //    r1 = is_reg(il.op1);
            //    switch (il.op2t)
            //    {
            //        case 3:
            //            il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
            //            if (r2 > 15 || r2 < 0) { error = -7; return false; }
            //            s2 = Convert.ToString(r2, 2).PadLeft(4, '0');
            //            il.word1 = "1001100" + s1 + s2 + "00";
            //            break;
            //        case 8:
            //            il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //            if (il.op2t == 8) r2 = (int)constlist[il.op2];
            //            if (r2 > 15 || r2 < 0) { error = -7; return false; }
            //            s2 = Convert.ToString(r2, 2).PadLeft(4, '0');
            //            il.word1 = "1001100" + s1 + s2 + "00";
            //            break;
            //        default:
            //            return false;
            //    }
            //}
            else return false;
            return true;
        }

        //private bool gen3(iline il, string op, char bwb)  // two params second 0-15
        //{
        //    int r1 = 0, r2 = 0; string s1, s2;
        //    il.op1t = parameter_type(il.op1);
        //    il.op2t = parameter_type(il.op2);
        //    if (il.op1t < 0 || il.op2t < 0) return false;
        //    if (il.op1t == 1)
        //    {
        //        r1 = is_reg(il.op1);
        //        switch (il.op2t)
        //        {
        //            case 3:
        //                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
        //                if (r2 > 15 || r2 < 0) { error = -7; return false; }
        //                s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
        //                il.word1 = op + s1 +bwb+ s2 + "00";
        //                break;
        //            case 8:
        //                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
        //                if (il.op2t == 8) r2 = (int)constlist[il.op2];
        //                if (r2 > 15 || r2 < 0) { error = -7; return false; }
        //                s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
        //                il.word1 = op + s1 +bwb+ s2 + "00";
        //                break;
        //            default:
        //                return false;
        //        }
        //    }
        //    else
        //        if (il.op1t == 4)
        //        {
        //            r1 = is_reg(il.op1);
        //            switch (il.op2t)
        //            {
        //                case 3:
        //                    il.len = 2; s1 = Convert.ToString(0, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
        //                    r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
        //                    if (r2 > 15 || r2 < 0) { error = -7; return false; }
        //                    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
        //                    il.word1 = op + s1 +bwb+ s2 + "11";
        //                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
        //                    il.word2 = il.word2.Substring(il.word2.Length - 16);
        //                    break;
        //                default:
        //                    return false;
        //            }
        //        }
        //        else
        //            if (il.op1t == 11)
        //            {
        //                r1 = is_reg(il.op1);
        //                switch (il.op2t)
        //                {
        //                    case 3:
        //                        il.len = 2; s1 = Convert.ToString(0, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
        //                        r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
        //                        if (r2 > 15 || r2 < 0) { error = -7; return false; }
        //                        s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
        //                        il.word1 = op + s1+bwb + s2 + "11";
        //                        //il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
        //                        //il.word2 = il.word2.Substring(il.word2.Length - 16);
        //                        break;
        //                    default:
        //                        return false;
        //                }
        //            }
        //            //else if (il.op1t == 9)
        //            //{
        //            //    r1 = is_reg(il.op1);
        //            //    switch (il.op2t)
        //            //    {
        //            //        case 3:
        //            //            il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
        //            //            if (r2 > 15 || r2 < 0) { error = -7; return false; }
        //            //            s2 = Convert.ToString(r2, 2).PadLeft(4, '0');
        //            //            il.word1 = "1001100" + s1 + s2 + "00";
        //            //            break;
        //            //        case 8:
        //            //            il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
        //            //            if (il.op2t == 8) r2 = (int)constlist[il.op2];
        //            //            if (r2 > 15 || r2 < 0) { error = -7; return false; }
        //            //            s2 = Convert.ToString(r2, 2).PadLeft(4, '0');
        //            //            il.word1 = "1001100" + s1 + s2 + "00";
        //            //            break;
        //            //        default:
        //            //            return false;
        //            //    }
        //            //}
        //            else return false;
        //    return true;
        //}   

        private bool gen4(iline il, string op)  // two params regs
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t < 0 || il.op2t < 0) return false;
            if (il.op1t == 1 || il.op1t==9 )
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case 1:
                    case 9:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = op + s1 + "0" + s2 + "00";
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool gen5(iline il, string op)  // one param for mainly for jumps
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t < 0 ) return false;
            switch (il.op1t)
            {
                case 1:
                    r1 = is_reg(il.op1);
                    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    il.word1 = op +  "0000" + s1 + "00";
                    break;
                case 2:
                    r1 = is_reg_ref(il.op1);
                    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    il.word1 = op + "0000" + s1 + "10";
                    break;
                case 3:
                    il.len = 2; r1 = conv_int(il.op1);
                    il.word1 = op +"0000000" + "01";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case 4:
                    il.len = 2;  r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                    il.word1 = op  + "0000000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case 6:
                case 7:
                case 8:
                    il.len = 2;
                    if (il.op1t == 6) r1 = (int) llist[il.op1];
                    if (il.op1t == 7) r1 = (int) vlist[il.op1];
                    if (il.op1t == 8) r1 = (int) constlist[il.op1];
                    il.word1 = op + "0000000" + "01";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case 12:
                case 13:
                case 14:
                    il.len = 2; 
                    s1 = il.op1.Substring(1, il.op1.Length - 2);
                    if (il.op1t == 12) r1 = (int)llist[s1];
                    if (il.op1t == 13) r1 = (int)vlist[s1];
                    if (il.op1t == 14) r1 = (int)constlist[s1];
                    il.word1 = op + "0000000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case 10:
                    il.len = 2; 
                    il.word1 = op + "0000000" + "01";
                    break;
                case 11:
                    il.len = 2; 
                    il.word1 = op + "0000000" + "11";
                    break;
                default:
                    return false;
            }
            return true;
        }

        private bool gen6(iline il, string op)  // one param for relative jumps
        {
            int r1 = 0, ii=0; string s1;
            il.op1t = parameter_type(il.op1);
            il.relative=true;
            if (il.op1t < 0) return false;
            ii = (int) address;
            switch (il.op1t)
            {
                case 1:
                    r1 = is_reg(il.op1);
                    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                    il.word1 = op + "0000" + s1 + "00";
                    break;
                case 2:
                    r1 = is_reg_ref(il.op1);
                    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); 
                    il.word1 = op + "0000" + s1 + "10";
                    break;
                case 3:
                    il.len = 2; r1 = conv_int(il.op1); //r1=address; 
                    il.word1 = op + "0000000" + "01";
                    il.word2 = Convert.ToString((Int16) r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case 4:
                    il.word2 = Convert.ToString((Int16) r1, 2).PadLeft(16, '0');
                    il.len = 2; r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                    il.word1 = op + "0000000" + "11";
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case 6:
                case 7:
                case 8:
                    il.len = 2;
                    if (il.op1t == 6) { r1 = (int)llist[il.op1];      r1 = r1-ii-4; }
                    if (il.op1t == 7) {r1 = (int)vlist[il.op1]; r1=r1-ii-4;}
                    if (il.op1t == 8) { r1 = (int)constlist[il.op1]; r1 = r1 - ii-4; }
                    il.word1 = op + "0000000" + "01";
                    il.word2 = Convert.ToString((Int16) r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case 12:
                case 13:
                case 14:
                    il.len = 2;
                    s1 = il.op1.Substring(1, il.op1.Length - 2);
                    if (il.op1t == 12) { r1 = (int)llist[s1]; }
                    if (il.op1t == 13) {r1 = (int)vlist[s1]; }
                    if (il.op1t == 14) { r1 = (int)constlist[s1]; }
                    il.word1 = op + "0000000" + "11";
                    il.word2 = Convert.ToString((Int16) r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case 10:
                    il.len = 2;
                    il.word1 = op + "0000000" + "01";
                    break;
                case 11:
                    il.len = 2;
                    il.word1 = op + "0000000" + "11";
                    break;
                default:
                    return false;
            }
            return true;
        }

        // 1 Reg   2  (Reg)  3 num  4 (num)  5 PC  6 LABEL  7 variable  8 constant  9 Breg XXX
        // 10 To be filled  11 (TBF)  12 (L)  13 (V)  14 (C)  15 SR  16 SP 

        private bool movr(iline il, char bwb)
        {
            int r1 = 0, r2 = 0, ii; string s1, s2;
            ii = (int) address;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            il.relative = true;
            if (il.op1t < 0 || il.op2t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s2 + bwb + s1 + "10";
                        break;
                    case 3:  // GADR
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "1111011" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 4:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "1111011" + s1 + bwb+ "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 6:  // GADR
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        r2 = r2 - ii - 4;
                        il.word1 = "1111011" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10: il.len = 2;  // GADR
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s1 + "0000" + "01";
                        break;
                    case 12:
                    case 13:
                    case 14:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == 12)  r2 = (int)llist[s2]; 
                        if (il.op2t == 13)  r2 = (int)vlist[s2]; 
                        if (il.op2t == 14)  r2 = (int)constlist[s2]; 
                        r2 = r2 - ii - 4; 
                        il.word1 = "1111011" + s1 +bwb+ "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 11: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s1 + bwb +"000" + "01";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 2)
            {
                r1 = is_reg_ref(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s1 + bwb + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s1 + bwb + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "1111011" + s1 + bwb+ "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "1111011" + s1 + bwb+ "000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;           
                    case 10: il.len = 2;
                        s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1111011" + s1 + bwb + "000" + "01";
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 4)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "111110"+ bwb + "000" + bwb + s2 + "01";
                        r2 = r2 - ii -4;
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case 3:
                    //    il.len = 3; r2 = conv_int(il.op2);
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    //case 6:
                    //case 7:
                    //case 8:
                    //    il.len = 3;
                    //    if (il.op2t == 6) r2 = (int)llist[il.op2];
                    //    if (il.op2t == 7) r2 = (int)vlist[il.op2];
                    //    if (il.op2t == 8) r2 = (int)constlist[il.op2];
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    //case 12:
                    //case 13:
                    //case 14:
                    //    il.len = 3; address += 2; r2 = conv_int(il.op2);
                    //    if (il.op2t == 6) r1 = (int)llist[il.op1];
                    //    if (il.op2t == 7) r1 = (int)vlist[il.op1];
                    //    if (il.op2t == 8) r1 = (int)constlist[il.op1];
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word2.Substring(il.word2.Length - 16);
                    //    break;
                    //case 10: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001001" + "0000" + s2 + "01";
                    //    break;
                    //case 11: il.len = 2;
                    //    r2 = is_reg(il.op2);
                    //    s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                    //    il.word1 = "1001001" + "0000" + s2 + "01";
                    //    break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 12 || il.op1t == 13 | il.op1t == 14)
            {
                if (il.op1t == 12) r1 = (int)llist[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == 13) r1 = (int)vlist[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == 14) r1 = (int)constlist[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "111110"+ bwb + "000" + bwb + s2 + "01";
                        r1 = r1 - ii - 4;
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    //case 3:
                    //    il.len = 3; r2 = conv_int(il.op2);
                    //    il.word1 = "1100000" + "0000000" + "01";
                    //    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    //    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    //    il.word3 = Convert.ToString(r2, 2).PadLeft(16, '0');
                    //    il.word3 = il.word3.Substring(il.word3.Length - 16);
                    //    break;
                    //case 6:
                    //case 7:
                    //case 8:
                    //    il.len = 3;
                    //    if (il.op2t == 6) r2 = (int)llist[il.op2];
                    //    if (il.op2t == 7) r2 = (int)vlist[il.op2];
                    //    if (il.op2t == 8) r2 = (int)constlist[il.op2];
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
            else if (il.op1t == 11)
            {
                // r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "111110"+ bwb + "000" + bwb + s2 + "01";
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

        private bool inc(iline il, char bwb)  // one param always a register bwb
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t < 0) return false;
            switch  (il.op1t) {
                 case 1:
                    if (il.op1t == 1)
                    {
                        r1 = is_reg(il.op1);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1000111" + s1 + bwb + "00000";
                    }
                    break;
                case 4:
                    il.len = 2;  r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                    il.word1 ="0111010"  + "000"+bwb +"000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case 11:
                    il.len = 2;
                    il.word1 = "0111010" + "000"+bwb +"000" + "11";
                    break;
                case 12:
                case 13:
                case 14:
                    il.len = 2; 
                    s1 = il.op1.Substring(1, il.op1.Length - 2);
                    if (il.op1t == 12) r1 = (int)llist[s1];
                    if (il.op1t == 13) r1 = (int)vlist[s1];
                    if (il.op1t == 14) r1 = (int)constlist[s1];
                    il.word1 = "0111010" + "000"+bwb +"000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
            //else
            //    if (il.op1t == 9 && (op == "1000111" || op == "1001000"))
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


        private bool dec(iline il, char bwb)  // one param always a register bwb
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t < 0) return false;
            switch (il.op1t)
            {
                case 1:
                    if (il.op1t == 1)
                    {
                        r1 = is_reg(il.op1);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        il.word1 = "1001000" + s1 + bwb + "00000";
                    }
                    break;
                case 4:
                    il.len = 2; r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                    il.word1 = "0100011" + "000" + bwb + "000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                case 11:
                    il.len = 2;
                    il.word1 = "0100011" + "000" + bwb + "000" + "11";
                    break;
                case 12:
                case 13:
                case 14:
                    il.len = 2;
                    s1 = il.op1.Substring(1, il.op1.Length - 2);
                    if (il.op1t == 12) r1 = (int)llist[s1];
                    if (il.op1t == 13) r1 = (int)vlist[s1];
                    if (il.op1t == 14) r1 = (int)constlist[s1];
                    il.word1 = "0100011" + "000" + bwb + "000" + "11";
                    il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                    il.word2 = il.word2.Substring(il.word2.Length - 16);
                    break;
                //else
                //    if (il.op1t == 9 && (op == "1000111" || op == "1001000"))
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

        private bool inter(iline il)  // one param for 0-16
        {
            int r1 = 0; 
            il.op1t = parameter_type(il.op1);
            if (il.op1t < 0) return false;
            switch (il.op1t)
            {
                case 3:
                    il.len = 1; r1 = conv_int(il.op1);
                    if (r1 > 15 || r1<0 ) { error = -7; return false; }
                    il.word1 = "1000001"+"000" +Convert.ToString(r1, 2).PadLeft(4, '0')+"00";
                    break;
                case 8:
                    il.len = 1;
                    if (il.op1t == 8) r1 = (int)constlist[il.op1];
                    if (r1 > 15 || r1 < 0) { error = -7; return false; }
                    il.word1 = "1000001" + "000" + Convert.ToString(r1, 2).PadLeft(4, '0') + "00";
                    break;
                default:
                    return false;
            }
            return true;
        }

        private bool push(iline il)
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                il.word1 = "0111011" + s1 + "000000";
            } 
            //else
            //if (il.op1t == 9)
            //{
            //    r1 = is_reg(il.op1);
            //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //    il.word1 = "1100010" + s1 + "000000";
            //}
            else if (il.op1t == 5)
            {
                r1 = is_reg(il.op1);
                il.len = 1; 
                il.word1 = "0111101" + "000000000";
            }
            else if (il.op1t == 15)
            {
                r1 = is_reg(il.op1);
                il.len = 1; 
                il.word1 = "0111100" + "000000000";
            }
            else   return false;
            return true;
        }

        private bool pop(iline il)
        {
            int r1 = 0; string s1;
            il.op1t = parameter_type(il.op1);
            if (il.op1t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                il.word1 = "1000000" + s1 + "000000";
            }
            //else
            //if (il.op1t == 9)
            //{
            //    r1 = is_reg(il.op1);
            //    il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
            //    il.word1 = "1100011" + s1 + "000000";
            //}
            else if (il.op1t == 5)
            {
                r1 = is_reg(il.op1);
                il.len = 1;
                il.word1 = "0111110" + "000000000";
            }
            else if (il.op1t == 15)
            {
                r1 = is_reg(il.op1);
                il.len = 1;
                il.word1 = "0111111" + "000000000";
            }
            else return false;
            return true;
        }

        private bool outop(iline il)
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t < 0 || il.op2t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000111" + s1 + "0" + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000111" + s1 + "0" + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "0000111" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 4:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "0000111" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "0000111" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 12:
                    case 13:
                    case 14:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == 12) r2 = (int)llist[s2];
                        if (il.op2t == 13) r2 = (int)vlist[s2];
                        if (il.op2t == 14) r2 = (int)constlist[s2];
                        il.word1 = "0000111" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10:
                    case 11:
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 3)
            {
                r1 = conv_int(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000111" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10:
                    case 11:
                        break;
                }
            }
            else if (il.op1t == 4)
            {
                r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000111" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10:
                    case 11:
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 12 || il.op1t == 13 | il.op1t == 14)
            {
                if (il.op1t == 12) r1 = (int)llist[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == 13) r1 = (int)vlist[il.op1.Substring(1, il.op1.Length - 2)];
                if (il.op1t == 14) r1 = (int)constlist[il.op1.Substring(1, il.op1.Length - 2)];
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000111" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10:
                    case 11:
                        break;
                    default:
                        return false;
                }
            }
            else if (il.op1t == 7 || il.op1t == 8)
            {
                if (il.op1t == 7) r1 = (int)vlist[il.op1];
                if (il.op1t == 8) r1 = (int)constlist[il.op1];
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "0000111" + "0000" + s2 + "01";
                        il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10:
                    case 11:
                        break;
                    default:
                        return false;
                }
            }
            else return false;
            return true;
        }

        private bool inop(iline il)
        {
            int r1 = 0, r2 = 0; string s1, s2;
            il.op1t = parameter_type(il.op1);
            il.op2t = parameter_type(il.op2);
            if (il.op1t < 0 || il.op2t < 0) return false;
            if (il.op1t == 1)
            {
                r1 = is_reg(il.op1);
                switch (il.op2t)
                {
                    case 1:
                        r2 = is_reg(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1000110" + s1 + "0" + s2 + "00";
                        break;
                    case 2:
                        r2 = is_reg_ref(il.op2);
                        il.len = 1; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
                        il.word1 = "1000110" + s1 + "0" + s2 + "10";
                        break;
                    case 3:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2);
                        il.word1 = "1000110" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 4:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0'); r2 = conv_int(il.op2.Substring(1, il.op2.Length - 2));
                        il.word1 = "1000110" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 6:
                    case 7:
                    case 8:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        if (il.op2t == 6) r2 = (int)llist[il.op2];
                        if (il.op2t == 7) r2 = (int)vlist[il.op2];
                        if (il.op2t == 8) r2 = (int)constlist[il.op2];
                        il.word1 = "1000110" + s1 + "0000" + "01";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 12:
                    case 13:
                    case 14:
                        il.len = 2; s1 = Convert.ToString(r1, 2).PadLeft(3, '0');
                        s2 = il.op2.Substring(1, il.op2.Length - 2);
                        if (il.op2t == 12) r2 = (int)llist[s2];
                        if (il.op2t == 13) r2 = (int)vlist[s2];
                        if (il.op2t == 14) r2 = (int)constlist[s2];
                        il.word1 = "1000110" + s1 + "0000" + "11";
                        il.word2 = Convert.ToString(r2, 2).PadLeft(16, '0');
                        il.word2 = il.word2.Substring(il.word2.Length - 16);
                        break;
                    case 10:
                    case 11:
                        break;
                    default:
                        return false;
                }
            }
            //else if (il.op1t == 3)
            //{
            //    r1 = conv_int(il.op1);
            //    switch (il.op2t)
            //    {
            //        case 1:
            //            r2 = is_reg(il.op2);
            //            il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
            //            il.word1 = "1001100" + "0000" + s2 + "01";
            //            il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
            //            il.word2 = il.word2.Substring(il.word2.Length - 16);
            //            break;
            //        case 10:
            //        case 11:
            //            break;
            //    }
            //}
            //else if (il.op1t == 4)
            //{
            //    r1 = conv_int(il.op1.Substring(1, il.op1.Length - 2));
            //    switch (il.op2t)
            //    {
            //        case 1:
            //            r2 = is_reg(il.op2);
            //            il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
            //            il.word1 = "1001100" + "0000" + s2 + "01";
            //            il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
            //            il.word2 = il.word2.Substring(il.word2.Length - 16);
            //            break;
            //        case 10:
            //        case 11:
            //            break;
            //        default:
            //            return false;
            //    }
            //}
            //else if (il.op1t == 12 || il.op1t == 13 | il.op1t == 14)
            //{
            //    if (il.op1t == 12) r1 = (int)llist[il.op1.Substring(1, il.op1.Length - 2)];
            //    if (il.op1t == 13) r1 = (int)vlist[il.op1.Substring(1, il.op1.Length - 2)];
            //    if (il.op1t == 14) r1 = (int)constlist[il.op1.Substring(1, il.op1.Length - 2)];
            //    switch (il.op2t)
            //    {
            //        case 1:
            //            r2 = is_reg(il.op2);
            //            il.len = 2; s2 = Convert.ToString(r2, 2).PadLeft(3, '0');
            //            il.word1 = "1001100" + "0000" + s2 + "01";
            //            il.word2 = Convert.ToString(r1, 2).PadLeft(16, '0');
            //            il.word2 = il.word2.Substring(il.word2.Length - 16);
            //            break;
            //        case 10:
            //        case 11:
            //            break;
            //        default:
            //            return false;
            //    }
            //}
            else return false;
            return true;
        }

        private int conv_int(string s)
        {
            int i = 0;
            if (((s[0] >= '0' && s[0] <= '9') || s[0] == '-') ) //&& int.TryParse(s, out i)
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
                try { i=Convert.ToInt32(s.Substring(1), 16); }
                catch { return 0; }
                return i;
            }
            if (s[0] == '#')
            {
                try { i=Convert.ToInt32(s.Substring(1), 2); }
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
            return i;
        }

        private bool Operation(iline il)
        {
            switch (il.opcode)
            {
                case "NOP":  il.len = 1; il.word1 = "0000000000000000";
                    break;
                case "MOV":
                    return mov(il);
                case "MOV.B":
                    return movb(il);
                case "ADD":
                    return gen1(il,"0000011",'0');
                case "SUB":
                    return gen1(il,"0000100",'0');
                case "ADC":
                    return gen1(il,"0000101");
                case "ADC.B":
                    return gen1(il, "0000101",'1');
                case "MOVHL":
                    return gen1(il, "1001100");
                case "MOVLH":
                    return gen1(il, "1001101");
                case "MOVHH":
                    return gen1(il, "1001110");
                case "ADD.B":
                    return gen1(il, "0000011",'1');
                case "SUB.B":
                    return gen1(il, "0000100",'1');
                case "ADDI":
                    return gen3(il, "1010100");
                case "SUBI":
                    return gen3(il, "1010011");
                //case "MUL.B":
                //    return gen1(il, "0001011",'1');
                case "SWAP":
                    return gen2(il, "0001000");
                case "CMP":
                    return cmpb(il, '0');
                case "CMP.B":
                    return cmpb(il,'1');
                case "AND":
                    return gen1(il, "0001111",'0');
                case "OR":
                    return gen1(il, "0010000",'0');
                case "XOR":
                    return gen1(il, "0010001",'0');
                case "NOT":
                    return gen2(il, "0010010",'0');
                case "AND.B":
                    return gen1(il, "0001111",'1');
                case "OR.B":
                    return gen1(il, "0010000",'1');
                case "XOR.B":
                    return gen1(il, "0010001",'1');
                case "NOT.B":
                    return gen2(il, "0010010",'1');
                case "SRA":
                    return gen3(il, "0011001");
                case "SLA":
                    return gen3(il, "0011010");
                case "SRL":
                    return gen3(il, "0011011");
                case "SLL":
                    return gen3(il, "0011100");
                //case "ROR":
                //    return gen3(il, "0110110");
                case "ROL":
                    return gen3(il, "0110110");
                //case "SRA.B":
                //    return gen3(il, "0011111");
                //case "SLA.B":
                //    return gen3(il, "0100000");
                case "SRL.B":
                    return gen3(il, "1001111");
                case "SLL.B":
                    return gen3(il, "1010000");
                //case "ROR.B":
                //    return gen3(il, "0100011");
                //case "ROL.B":
                //    return gen3(il, "0100100");
                case "JMP":
                    return gen5(il, "0100101");
                case "JZ":
                    return gen5(il, "0100110");
                case "JNZ":
                    return gen5(il, "0100111");
                case "JO":
                    return gen5(il, "0101000");
                case "JNO":
                    return gen5(il, "0101001");
                case "JC":
                case "JB":
                    return gen5(il, "0101010");
                case "JL":
                    return gen5(il, "0110001");
                case "JNC":
                    return gen5(il, "0101011");
                case "JN":
                    return gen5(il, "0101100");
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
                case "JRZ":
                    return gen6(il, "1110001");
                case "JRN":
                    return gen6(il, "1110010");
                case "JRO":
                    return gen6(il, "1110011");
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
                    return inter(il);
                case "RETI": il.len = 1; il.word1 = "1000010000000000";
                    break;
                case "CLI": il.len = 1; il.word1 = "1000011000000000";
                    break;
                case "STI": il.len = 1; il.word1 = "1000100000000000";
                    break;
                case "OUT":
                    return outop(il);
                case "IN":
                    return inop(il);
                case "JRBE":
                    return gen6(il, "1110111");
                case "JRA":
                    return gen6(il, "1111010");
                case "INC":
                    return inc(il, '0');
                case "DEC":
                    return dec(il,'0');
                case "INC.B":
                    return inc(il, '1');
                case "DEC.B":
                    return dec(il, '1');
                case "JLE":
                    return gen5(il, "0111000");
                case "JG":
                    return gen5(il, "0111001");
                case "JRLE":
                    return gen6(il, "1111000");
                case "JRG":
                    return gen6(il, "1110101");
                case "BTST":
                    return gen3(il, "0010110");
                case "BSET":
                    return gen3(il, "0010111");
                case "BCLR":
                    return gen3(il, "0011000");
                case "MULU.B":
                    return gen1(il, "0001010",'1');
                case "MULU":
                    return gen1(il, "0001010", '0');
                case "JRNZ":
                    return gen6(il, "1111001");
                case "MOVI":
                    return gen3(il, "0100000");
                case "MOVI.B":
                    return gen3(il, "0100010");
                case "CMPI":
                    return gen3(il, "1010010");
                case "CMPI.B":
                    return gen3(il, "0110000");
                case "SETX":
                    return gen5(il, "0010011");
                case "JMPX":
                    return gen5(il, "0010100");
                case "MOVX":
                    return gen2(il, "0010101");
                case "SETSP":
                    return gen5(il, "0001001");
                case "GETSP":
                    return gen2(il, "1000101");
                //case "CMPHL":
                //    return gen5(il, "1001011");
                case "MOVR":
                    return movr(il,'0');
                case "GADR":
                    return movr(il, '0');
                case "MOVR.B":
                    return movr(il, '1');
                case "PUSHX": il.len = 1; il.word1 = "0111101000000000";  //
                    break;
                case "POPX": il.len = 1; il.word1 = "0111110000000000";
                    break;
            }
            return true;
        }

        private  bool add_oper(iline il)
        {
            bool res;
            il.opno = (int) ilist[t];
            il.type = 3; il.opcode = t;
            if (address % 2 == 1)
            {
                il.address = address + 1;
                L.errorbox.Text += " Warning operation at line: " + il.lno.ToString()  + " automaticly alinged to even address\r\n";
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
            res=Operation(il);
            if (!res) if (error>=0) error = -4;
            if (address % 2 == 1) address = (ushort) (address + 1);
            address = (ushort) (address +  2 * il.len);
            return res;
        }

        private bool add_dir(iline il)
        {
            bool res; ushort w; int i;
            if (t=="ORG")    {
                    il.opcode = t;
                    t="";
                    res = get_next_token();
                    if (!res) { error = -1; return false; }
                    if (t[0] == '$')
                    {
                        try { i = Convert.ToInt32(t.Substring(1), 16); }
                        catch { return false; }
                    }
                    else   if (t[0] == '#')
                    {
                        try { i = Convert.ToInt32(t.Substring(1), 2); }
                        catch { return false; }
                    }
                    else
                    {
                        if (!ushort.TryParse(t, out w)) { error = -2; return false; }
                    }
                    address = (ushort) conv_int(t); il.address = address;
                    if (address > 65535) { error = -7; return false; }
                }
                else if (t == "END")
                {
                    il.opcode = t;
                }
                else if (t == "DS")
                {
                    il.opcode = t;
                    t = "";
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
                    if (address > 65535) { error = -7;  return false; }
                    il.address = address;
                }
                else if (t == "DB" || t == "DW" || t == "TEXT" || t=="DA")
                {
                    il.opcode = t;
                    res=add_var_values(il);
                    return res;
                }
            il.type = 1; 
            return true;
        }

        private bool is_num(string s)
        {
            int i;
           // int result = (int)new DataTable().Compute("1 + 2 * 7", null);
            
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
                i = (int) s[1];
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
                try
                {
                    i = (int)new DataTable().Compute(s, null);
                    t = i.ToString();
                }
                catch
                {
                    error = -2; return false;
                }
            }
            return true;
        }

        private bool add_var(iline il)
        {
            bool res;  int v;
            il.variable = t; il.address = address;
            t = "";
            res = get_next_token();
            if (!res) { error = -1;  return false; }
            if (t == "EQU")
            {
                il.type = 4;
                t = "";
                res = get_next_token();
                if (!res) { error = -1; return false; }
                if (is_num(t))
                {
                    v = (ushort)conv_int(t);
                }
                else return false;
                try
                {
                    constlist.Add(il.variable, v);
                }
                catch
                {
                    error = -5;
                    return false;
                }
            }
            else if (t == "DB")
            {
                t = ""; il.merge = false;
                try { vlist.Add(il.variable, (int)address); }
                catch
                {
                    error = -5;
                    return false;
                }
                il.values = new ArrayList();
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
                        t = "";
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
                        t = "";
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
                        t = "";
                        if (res = get_next_token2())
                        {
                            if (is_num(t))
                            {
                                v = (ushort)conv_int(t) * 256;
                                address += 1;
                                il.len += 1;
                            }
                            else return false;
                        }
                        t = "";
                    }
                    if (il.len > 1 && il.len % 2 == 0)
                    {
                        il.values.Add((int)v);
                    }
                }
                il.type = 5;
            }
            else if (t == "TEXT")
            {
                t = ""; il.merge = false;
                try { vlist.Add(il.variable, (int)address); }
                catch
                {
                    error = -5;
                    return false;
                }
                il.values = new ArrayList();
                res = get_first_char();
                if (t != "\"" || !res) { error = -2; return false; }
                if (address % 2 == 0)
                {
                    while (res = get_next_char())
                    {
                        v = (ushort)t[0];
                        v = v * 256;
                        address += 1; il.len += 1;
                        t = "";
                        if (res = get_next_char())
                        {
                            v = v + (ushort)t[0];
                            address += 1; il.len += 1;
                        }
                        else il.merge = true;
                        il.values.Add((int)v);
                        t = "";
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
                        t = "";
                        if (res = get_next_char())
                        {
                            v = (ushort)t[0] * 256;
                            address += 1; il.len += 1;
                            t = "";
                        }
                        else break;
                    }
                    if (t != "\"") { error = -2; return false; }

                    if (il.len > 1 && il.len % 2 == 0)
                    {
                        il.values.Add((int)v);
                    }
                }
                il.type = 5;
            }
            else if (t == "DW")
            {
                if (address % 2 == 1) { address += 1; il.address = address;
                    //L.errorbox.Text += " Warning Label " + t + " automaticly alinged to even address\r\n";
                }
                t = "";
                il.values = new ArrayList();
                try
                {
                    vlist.Add(il.variable, (int)address);
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
                    t = "";
                }
                il.type = 6;
            }
            else if (t == "DS")
            {
                int i;
                il.opcode = t;
                t = "";
                try { vlist.Add(il.variable, (int)address); }
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
                if (address % 2 == 1) { address += 1; il.address = address;
                   // L.errorbox.Text += " Warning Label " + t + " automaticly alinged to even address\r\n";
                }
                t = "";
                try { vlist.Add(il.variable, (int)address); }
                catch
                {
                    error = -5;
                    return false;
                }
                res = get_next_token2();
                if (res)
                {
                    il.op1t = 10;
                    il.op1 = t;
                    il.type = 16;
                }
                else return false;
                address += 2;
                t = "";
            }
            else return false;
            return true;
        }

        private bool add_var_values(iline il)
        {
            bool res; int v;
            il.address = address;
            if (t == "EQU")
            {
                il.type = 4;
                t = "";
                res = get_next_token();
                if (!res) { error = -1; return false; }
                if (is_num(t))
                {
                    v = (ushort)conv_int(t);
                }
                else return false;
                try
                {
                    constlist.Add(il.variable, v);
                }
                catch
                {
                    error = -5;
                    return false;
                }
            }
            else if (t == "DB")
            {
                t = ""; il.merge = false;
                il.values = new ArrayList();
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
                        t = "";
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
                        t = "";
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
                        t = "";
                        if (res = get_next_token2())
                        {
                            if (is_num(t))
                            {
                                v = (ushort)conv_int(t) * 256;
                                address += 1;
                                il.len += 1;
                            }
                            else return false;
                        }
                        t = "";
                    }
                    if (il.len > 1 && il.len % 2 == 0)
                    {
                        il.values.Add((int)v);
                    }
                }
                il.type = 5;
            }
            else if (t == "TEXT")
            {
                t = ""; il.merge = false;
                il.values = new ArrayList();
                res = get_first_char();
                if (t != "\"" || !res) { error = -2; return false; }
                if (address % 2 == 0)
                {
                    while (res = get_next_char())
                    {
                        v = (ushort)t[0];
                        v = v * 256;
                        address += 1; il.len += 1;
                        t = "";
                        if (res = get_next_char())
                        {
                            v = v + (ushort)t[0];
                            address += 1; il.len += 1;
                        }
                        else il.merge = true;
                        il.values.Add((int)v);
                        t = "";
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
                        t = "";
                        if (res = get_next_char())
                        {
                            v = (ushort)t[0] * 256;
                            address += 1; il.len += 1;
                            t = "";
                        }
                        else break;
                    }
                    if (t != "\"") { error = -2; return false; }

                    if (il.len > 1 && il.len % 2 == 0)
                    {
                        il.values.Add((int)v);
                    }
                }
                il.type = 5;
            }
            else if (t == "DW")
            {
                if (address % 2 == 1) { address += 1; il.address = address;
                //L.errorbox.Text += " Warning Label " + t + " automaticly alinged to even address\r\n";
                }
                t = "";
                il.values = new ArrayList();
                while (res = get_next_token2())
                {
                    if (is_num(t))
                    {
                        v = (ushort)conv_int(t);
                    }
                    else return false;
                    il.values.Add((int)v);
                    address += 2;
                    t = "";
                }
                il.type = 6;
            }
            else if (t == "DA")
            {
                if (address % 2 == 1) { address += 1; il.address = address;
                   // L.errorbox.Text += " Warning Label " + t + " automaticly alinged to even address\r\n"; 
                }
                t = "";
                res = get_next_token2();
                if (res)
                {
                    il.op1t = 10;
                    il.op1 = t;
                    il.type = 16;
                }
                else return false;
                address += 2;
                t = "";
            }
            else return false;
            return true;
        }

        private bool parse_line()
        {
            bool res,ok;
            //int carry=0;
            iline il;
            t = "";
            ok = true;
            while ((res = get_next_token()) && ok)
            {
                il = new iline(l);
                if (t[t.Length - 1] == ':') ok =add_label(il);
                else if (ilist.ContainsKey(t))  ok = add_oper(il); 
                else if (dlist.ContainsKey(t))  ok = add_dir(il); 
                else ok=add_var(il);
                if (ok)
                {            
                    if (il.merge && instlist.Count>0)
                    {
                        iline ill = (iline)instlist[instlist.Count - 1];
                        if (ill.merge)
                        {
                            int i = 0;
                            foreach (int ii in il.values)
                            {
                                if (i == 0)
                                {
                                    ill.values[ill.values.Count - 1] = (int)ill.values[ill.values.Count - 1] + ii;
                                    //carry = 0;
                                }
                                else
                                {
                                    ill.values.Add((int)ii);
                                }
                                i++;
                            }
                            if (i % 2 == 0) ill.merge = true; else ill.merge = false;
                        }
                        else
                        {
                            instlist.Add(il);
                            lastline = il;
                        }
                    }
                    else
                    {
                        instlist.Add(il);
                        lastline = il ;
                    }
                    //if (il.word1 != "")
                    //{
                    //    L.VHDL.Text += "tmp(" + Convert.ToString(il.address / 2) + "):=\"" + il.word1 + "\"; ";
                    //    if (il.word2 != "") L.VHDL.Text += "tmp(" + Convert.ToString(1 + il.address / 2) + "):=\"" + il.word2 + "\";";
                    //    L.VHDL.Text += "\r\n";
                    //}
                    //if (il.type == 6 || il.type == 5)
                    //{
                    //    int ad = il.address;
                    //    foreach (int i in il.values)
                    //    {
                    //        string s = Convert.ToString(i, 2).PadLeft(16, '0');
                    //        s = s.Substring(s.Length - 16);
                    //        L.VHDL.Text += "tmp(" + Convert.ToString(ad / 2) + "):=\"" + s + "\"; \r\n";
                    //        ad = ad + 2;
                    //    }
                    //}
                }
                else { if (error>=0) error = -6; return false; }
                t = "";
            }
            return ok;
        }

        private bool pass1()
        {
            bool res = true; l = 0; error = 0;
            L.errorbox.Text += "Pass1 - start \r\n";
            while (l<clines.Length && res)
            {
                p = 0;
                res=parse_line();
                l+=1;
            }
            if (error<0 ) {
                L.errorbox.Text += "Error " + errlist[-error] + " at line: " + Convert.ToString(l)+" \r\n";
                return false;
            }
             L.errorbox.Text += "Pass1 - end \r\n";
            return true;
        }

        private bool pass2()
        {
            bool f = true; int i=0, ad=0;
            BinaryWriter bw = null;
            string temps = "";
            L.VHDL.Text = "";

            //create the bin file
            try
            {
                bw = new BinaryWriter(new FileStream(L.fname+".bin", FileMode.Create));
            }
            catch (IOException e)
            {
            }

            //create the mif file
            StreamWriter sw = new StreamWriter(L.fname+".mif", false, System.Text.Encoding.GetEncoding(1253));
            sw.WriteLine("WIDTH=16;\nDEPTH=4096;\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\n\nCONTENT BEGIN\n\n");

            foreach (iline il in instlist)
            {
                if (il.opcode == "ORG") temps += "\r\n"; 
                if (il.op1t == 10 || il.op1t == 11)
                {   
                    string s = il.op1; f = false;
                    if (il.op1t == 11) s = s.Substring(1, s.Length  - 2);
                    if (llist.ContainsKey(s)) { i =  (int)llist[s]; f =true; }
                    if (constlist.ContainsKey(s)) { i = (int) constlist[s];  f =  true; }
                    if (vlist.ContainsKey(s)) { i = (int) vlist[s];  f =  true; }
                    if (f)
                    {
                        if (il.relative) { il.word2 = Convert.ToString((Int16)i - il.address - il.len * 2, 2).PadLeft(16, '0'); } 
                        else  il.word2 = Convert.ToString(i, 2).PadLeft(16, '0');
                        if (il.type == 16)  //  DA command
                        {
                            il.word1 = il.word2;
                            il.word2 = "";
                        }
                    } else {
                        L.errorbox.Text+="Unknown identifier "+s+" at line: "+(il.lno+1).ToString()+" \r\n";
                        return false;
                    };
                }
         
                if (il.op2t == 10 || il.op2t == 11)
                {
                    string s = il.op2; f = false;
                    if (il.op2t == 11) s = s.Substring(1, s.Length - 2);
                    if (llist.ContainsKey(s)) { i = (int)llist[s]; f = true; }
                    if (constlist.ContainsKey(s)) { i = (int)constlist[s]; f = true; }
                    if (vlist.ContainsKey(s)) { i = (int)vlist[s]; f = true; }
                    if (f)
                    {
                        if ((il.relative && il.op2t == 10) || il.opcode=="MOVR" ) {
                            if (il.len != 3) il.word2 = Convert.ToString((Int16)i - il.address - il.len * 2, 2).PadLeft(16, '0');
                            else il.word3 = Convert.ToString((Int16)i - il.address - il.len*2, 2).PadLeft(16, '0');
                        }
                        else
                            if (il.len != 3) il.word2 = Convert.ToString(i, 2).PadLeft(16, '0');
                            else il.word3 = Convert.ToString(i, 2).PadLeft(16, '0');
                    }
                    else
                    {
                        L.errorbox.Text += "Unknown identifier " + s + " at line: " + (il.lno + 1).ToString() + " \r\n";
                        return false;
                    };
                }
                if (il.word1 != "")
                {
                    if (il.address > 8191) ad = il.address - 8192; else ad = il.address;
                    temps += "tmp(" + Convert.ToString(ad / 2) + "):=\"" + il.word1 + "\"; ";
                    if (il.word2 != "") temps += "tmp(" + Convert.ToString(1+ad / 2) + "):=\"" + il.word2 + "\";";
                    if (il.word3 != "") temps += " tmp(" + Convert.ToString(2 + ad / 2) + "):=\"" + il.word3 + "\";";
                    temps += " --" + il.opcode + " \r\n";
                    try
                    {
                        bw.Seek(ad,0);
                        bw.Write(Convert.ToByte(il.word1.Substring(0,8),2));
                        bw.Write(Convert.ToByte(il.word1.Substring(8, 8), 2));
                        sw.WriteLine(Convert.ToString(ad / 2)+" : "+il.word1 +";");
                        if (il.word2 != "")
                        {
                            bw.Write(Convert.ToByte(il.word2.Substring(0, 8), 2));
                            bw.Write(Convert.ToByte(il.word2.Substring(8, 8), 2));
                            sw.WriteLine(Convert.ToString(1+ad / 2)+" : "+il.word2 +";");
                        }
                        if (il.word3 != "")
                        {
                            bw.Write(Convert.ToByte(il.word3.Substring(0, 8), 2));
                            bw.Write(Convert.ToByte(il.word3.Substring(8, 8), 2));
                            sw.WriteLine(Convert.ToString(2+ad / 2)+" : "+il.word3 +";");
                        }
                    }
                    catch (IOException e)
                    {
                    }
                }
                if (il.type == 6 || il.type==5)
                {
                    if (il.address > 8191) ad = il.address - 8192; else ad = il.address;
                    int rr = 0;
                    foreach (int ii in il.values)
                    {
                        string s=Convert.ToString(ii, 2).PadLeft(16, '0');
                        s = s.Substring(s.Length - 16);
                        temps += "tmp(" + Convert.ToString(ad / 2) + "):=\"" + s + "\"; ";
                        try
                        {
                            bw.Seek(ad, 0);
                            bw.Write(Convert.ToByte(s.Substring(0, 8), 2));
                            bw.Write(Convert.ToByte(s.Substring(8, 8), 2));
                            sw.WriteLine(Convert.ToString(ad / 2)+" : "+s +";");
                        }
                        catch (IOException e)
                        {
                        }
                        ad = ad + 2;
                        if (rr % 2 == 1) temps += "\r\n";
                        rr++;
                    }
                    if (rr % 2 == 1) temps += "\r\n";
                }
            }
            L.VHDL.Text = temps;
            bw.Close();
            sw.WriteLine("END;\n");
            sw.Close();
            return f;
        }

        public void  parse()
        {
            bool res; int i,cp;
            instlist.Clear();
            constlist.Clear();
            vlist.Clear();
            llist.Clear();
            clines=L.source.Lines;
            L.VHDL.Text = "-- Copy to LionSystem VHDL Rom or Ram init function\r\n";
            address = 32;
            error = 0; L.errorbox.Text = "";
            for (i = 0; i < clines.Length; i++)
            {
                cp = clines[i].IndexOf(';');
                if ( cp != -1) clines[i] = clines[i].Substring(0,cp);
            }
            for (i = 0; i < clines.Length; i++) clines[i] = clines[i].ToUpper();
            res = pass1();
            if (res )
            {
                if (L.Displv.Checked)
                {
                    foreach (string k in llist.Keys)
                    {
                        L.errorbox.Text += k + ": " + Convert.ToString((int)llist[k], 2).PadLeft(16, '0') + " \r\n";
                    }
                    foreach (string p in vlist.Keys)
                    {
                        L.errorbox.Text += p + ": " + Convert.ToString((int)vlist[p], 2).PadLeft(16, '0') + " \r\n";
                    }
                }
                L.VHDL.Text = "-- Copy to LionSystem VHDL Rom or Ram init function\r\n";
                res = pass2();
                if (!res)
                {
                    L.errorbox.Text += " Pass 2 failed. \r\n";
                }
                else { L.errorbox.Text += " Pass 2 end. \r\n"; }
            }
            else { L.errorbox.Text += " Pass 1 failed. \r\n"; }
            L.errorbox.SelectionStart = L.errorbox.TextLength;
            L.errorbox.ScrollToCaret();
        }

        public aparser(Lionasm LL)
        {
            L = LL;
            fill_clist();
            fill_ilist();
            fill_dlist();
        }

    }
}
