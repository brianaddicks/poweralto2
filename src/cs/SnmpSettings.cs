namespace PowerAlto {
	public class SnmpSettings : PowerAltoBaseObject {
		public string Location;
		public string Contact;
		public bool EventSpecificTraps;
		public string Version;
		public string Community;
		
		public string BaseXPath {
			get {
				return "/config/devices/entry/deviceconfig/system/snmp-setting";
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
		
	}
}