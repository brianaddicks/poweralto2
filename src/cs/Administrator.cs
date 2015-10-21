namespace PowerAlto {
  public class Administrator : PowerAltoBaseObject {
    public string Name { get; set; }
    public string AuthenticationProfile { get; set; }
	public bool UseCertificate;
	public bool UseSshKey;
	public string AdminType;
	public string Role;
	public string PasswordProfile;
	
	public string BaseXPath {
		get {
			return "/config/mgt-config/users";
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