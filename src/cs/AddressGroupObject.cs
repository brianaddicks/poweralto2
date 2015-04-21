namespace PowerAlto {
  public class AddressGroupObject : PowerAltoBaseObject {
    public string Name { get; set; }
    public string Description { get; set; }
	public string Type { get; set; }
	public string Filter { get; set; }
	public List<string> Members { get; set; }
	public List<string> Tags { get; set; }
	
	public string BaseXPath {
		get {
			return "/config/devices/entry/vsys/entry/address-group";
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

			//XmlObject.Element("entry").Add( createXmlWithoutMembers( this.addressType, this.address));	// Address
			//XmlObject.Element("entry").Add( createXmlWithMembers( "tag", this.Tags, false ));			      // Tags
			//XmlObject.Element("entry").Add( createXmlWithoutMembers( "description", this.Description));	// Description
			

			return XmlObject.Element("entry");
	  }
  }
}