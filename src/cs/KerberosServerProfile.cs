namespace PowerAlto {
  public class KerberosServerProfile : PowerAltoBaseObject {
    public string Name;
	public bool AdminUseOnly;
	public string Realm;
	public string Domain;
	public List<KerberosServer> Servers;
	
	public string BaseXPath {
		get {
			return "/config/shared/server-profile/kerberos";
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