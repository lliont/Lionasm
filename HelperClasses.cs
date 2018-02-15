using System.Collections.Generic;

namespace Lion_assembler
{
    public class DasmSymbol
    {
        public string Name;
        public string HexValue;
        public string BinaryValue;
        public uint DecimalValue;
        public bool isLabel;
    }

    public class DasmRecord
    {
        public List<DasmSymbol> SymbolsList = new List<DasmSymbol>();
    }
}
