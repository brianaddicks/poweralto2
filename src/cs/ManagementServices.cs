namespace PowerAlto {
	public class ManagementServices : PowerAltoBaseObject {
		public bool DisableHttp;
		public bool DisableHttpOcsp;
		public bool DisableHttps;
		public bool DisableIcmp;
		public bool DisableSnmp;
		public bool DisableSsh;
		public bool DisableTelnet;
		public bool DisableUserId;
		public bool DisableSyslogSsl;
		public bool DisableSyslogUdp;
		
		public string BaseXPath {
			get {
				return "/config/devices/entry/deviceconfig/system/service";
			}
		}
		
		public string XPath {
			get {
				return this.BaseXPath;
			}
		}
		
		public override XElement Xml () {
                    
			// Create root
			XDocument XmlObject = new XDocument();
			
			// create entry nod and define name attribute
			XElement xmlEntry = new XElement("entry");

			XmlObject.Add(xmlEntry);			

			return XmlObject.Element("entry");
		}
		
		public ManagementServices () {
			this.DisableHttpOcsp  = true;
			this.DisableSyslogSsl = true;
			this.DisableSyslogUdp = true;
		}    
	}
}