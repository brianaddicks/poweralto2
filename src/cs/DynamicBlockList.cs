namespace PowerAlto {
	public class DynamicBlockList : PowerAltoBaseObject {
		public string Name;
		public string Description;
		public string Source;
		public string UpdateInterval;
		public string UpdateTime;
		
		public string BaseXPath {
			get {
				return "/config/devices/entry/vsys/entry/external-list";
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