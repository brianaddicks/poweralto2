namespace PowerAlto {
	public class LdapServerProfile : PowerAltoBaseObject {
		public string Name;
		public bool AdminUseOnly;
		public List<LdapServer> Servers;
		
		public string Domain;
		public string Type;
		public string Base;
		public string BindDn;
		public string BindPassword;
		
		public bool Ssl;
		public int TimeLimit;
		public int BindTimeLimit;
		public int RetryInterval;
		
		public string BaseXPath {
			get {
				return "/config/shared/server-profile/ldap";
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
		
		public LdapServerProfile () {
			this.TimeLimit = 30;
			this.BindTimeLimit = 30;
		}    
	}
}