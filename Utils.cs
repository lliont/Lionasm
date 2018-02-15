using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using System.IO;

namespace Lion_assembler
{
    public static class Utils
    {
        private static string AppRunPath;
        private static string LogFileName;

        static Utils()
        {
            AppRunPath = AppDomain.CurrentDomain.BaseDirectory;
            LogFileName = "Log_" + System.Diagnostics.Process.GetCurrentProcess().ProcessName + "_#.txt";
        }

#if LOG
        public static void Log(string strToLog, params object[] args)
        {
            Console.WriteLine(strToLog, args);

            string mylogfname = LogFileName.Replace("#", DateTime.Now.ToString("yyyyMMdd"));

            using (StreamWriter f = File.AppendText(AppRunPath + @"\" + mylogfname))
            {
                string timestamp = DateTime.Now.ToString("yyyyMMdd") + "|" + DateTime.Now.ToString("HH:mm:ss:fff");
                f.WriteLine(string.Format("{0}|{1}", timestamp, args.Length > 0 ? string.Format(strToLog, args) : strToLog));
                f.Close();
            }
        }
#endif

        /// <summary>
        /// write an object to xml file
        /// </summary>
        public static void WriteObjectToXML(object theObject)
        {
            string fname = theObject.ToString() + ".xml";
            WriteObjectToXML(theObject, fname);
        }

        public static void WriteObjectToXML(object theObject, string fname)
        {
            try
            {
                if (string.IsNullOrEmpty(fname))
                {
                    fname = theObject.ToString() + ".xml";
                }
                if (!Directory.Exists(Path.GetDirectoryName(fname)))
                {
                    fname = Path.Combine(System.Windows.Forms.Application.StartupPath, fname);
                }
                XmlSerializer x = new XmlSerializer(theObject.GetType());
                using (XmlTextWriter xmlwr = new XmlTextWriter(fname, Encoding.UTF8))
                {
                    xmlwr.Formatting = Formatting.Indented;
                    var ns = new XmlSerializerNamespaces();
                    ns.Add(string.Empty, string.Empty);
                    x.Serialize(xmlwr, theObject, ns);
                }
            }
            catch (Exception e)
            {
#if LOG
                Log("EXCEPTION in WriteObjectToXML ( {0} ) : {1}" ,fname, e.Message);
#endif
            }
        }
    }
}
