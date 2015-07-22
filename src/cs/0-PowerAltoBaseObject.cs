using System.Text.RegularExpressions;

namespace PowerAlto {
  public abstract class PowerAltoBaseObject {
  
    protected string nameAlphaNumDashDotUnder (string Name, int Length) {
      string namePattern =  @"^[a-zA-Z0-9\-_\.\ ]{1," + Length + @"}$";
      Regex nameRx = new Regex(namePattern);
      Match nameMatch = nameRx.Match(Name);
      if (nameMatch.Success) {
        return Name;
      } else {
        string errorMessage = null;
        if (Name.Length > Length) {
          errorMessage = "Value must be less that " + Length + " characters or less." + Name.Length;
        } else {
          errorMessage = "Value must contain only alphanumeric, hyphens, underscores, spaces, or periods.";
        }
        throw new System.ArgumentException(errorMessage);
      }
    }
    
    protected XElement createXmlWithMembers( string XmlKeyword, List<string> RuleProperty = null, bool Required = false) {
			XElement nodeXml = new XElement(XmlKeyword);
			if (RuleProperty != null) {
				foreach (string member in RuleProperty) {
					nodeXml.Add(
						new XElement("member",member)
					);
				}
			} else {
				if (!(Required)) {
					return null;
				}
				nodeXml.Add(
					new XElement("member","any")
				);
			}
			return nodeXml;
		}
    
    protected XElement createXmlWithoutMembers( string XmlKeyword, string XmlValue = null) {
			if (!(String.IsNullOrEmpty(XmlValue))) {
				XElement nodeXml = new XElement(XmlKeyword,XmlValue);
				return nodeXml;
			} else {
				return null;
			}
		}
    
    protected XElement createXmlWithSingleMember( string XmlKeyword, string RuleProperty = null) {
			XElement nodeXml = new XElement(XmlKeyword);
			if (RuleProperty != null) {
				nodeXml.Add( new XElement( "member",RuleProperty ));
				return nodeXml;
			} else {
				return null;
			}
		}
    
    protected XElement createXmlBool( string XmlKeyword, bool xmlValue ) {
			XElement nodeXml = new XElement(XmlKeyword);
			if (xmlValue) {
				nodeXml.Value = "yes";
			} else {
				nodeXml.Value = "no";
			}
			return nodeXml;
		}

    // -------------------- Xml Output Classes ---------------------- //
    public abstract XElement Xml();
    
    public string PrintPrettyXml() {
			return Xml().ToString();
		}

		public string PrintPlainXml() {
      return Xml().ToString(SaveOptions.DisableFormatting);
		}
    // -------------------- End Xml Output Classes ---------------------- //
    
    // ----------------- CLI Methods ----------------- //
    protected string createCliWithoutMembers( string CliKeyword, string RuleProperty) {
			string CliObject = "";
			if (RuleProperty != null) {
				CliObject += " " + CliKeyword + " " + RuleProperty;
			}
			return CliObject;
		}

		protected string createReqCliWithMembers( string CliKeyword, List<string> RuleProperty = null) {
			string CliObject = "";
			if (RuleProperty != null) {
				CliObject += " " + CliKeyword + " [";
				foreach (string r in RuleProperty) {
					CliObject += " " + r;
				}
				CliObject += " ]";
			} else {
				CliObject += " " + CliKeyword + " any";
			}
			return CliObject;
		}

		protected string createCliWithMembers( string CliKeyword, List<string> RuleProperty = null) {
			string CliObject = "";
			if (RuleProperty != null) {
				CliObject += " " + CliKeyword + " [";
				foreach (string r in RuleProperty) {
					CliObject += " " + r;
				}
				CliObject += " ]";
			}
			return CliObject;
		}

		protected string createCliBool( string CliKeyword, bool RuleProperty ) {
			string CliObject = "";
			if (RuleProperty) {
				CliObject += " " + CliKeyword + " yes";
			} else {
				CliObject += " " + CliKeyword + " no";
			}
			return CliObject;
		}
    // --------------- End CLI Methods --------------- //

  }
}