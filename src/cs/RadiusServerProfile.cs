namespace PowerAlto {
	public class RadiusServerProfile : PowerAltoBaseObject {
		public string Name;
		public bool AdminUseOnly;
		public string Domain;
		public int Timeout;
		public int Retries;
		public bool RetrieveUserGroup;
		public List<RadiusServer> Servers;
		
		public string BaseXPath {
			get {
				return "/config/shared/server-profile/radius";
			}
		}
		
		public string XPath {
			get {
				return this.BaseXPath + "/entry[@name='" + this.Name + "']";
			}
		}
		
		public override XElement Xml () {
                    
			// Create root
			XDocument XmlObject = new XDocument();
			
			// create entry nod and define name attribute
			XElement xmlEntry = new XElement("entry");
			xmlEntry.SetAttributeValue("name",this.Name);
			XmlObject.Add(xmlEntry);			

			return XmlObject.Element("entry");
		}
	}
}