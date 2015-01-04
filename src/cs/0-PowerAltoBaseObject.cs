using System.Text.RegularExpressions;

namespace PowerAlto {
  public class PowerAltoBaseObject {
    protected string nameAlphaNumDashDotUnder (string Name, int Length) {
      string namePattern =  @"^[a-zA-Z0-9\-_\.]{1," + Length + "}$";
      Regex nameRx = new Regex(namePattern);
      Match nameMatch = nameRx.Match(Name);
      if (nameMatch.Success) {
        return Name;
      } else {
        string errorMessage = null;
        if (Name.Length > Length) {
          errorMessage = "Value must be less that 15 characters or less.";
        } else {
          errorMessage = "Value must contain only alphanumeric, hyphens, underscores, or periods.";
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
    
    protected string printPlainXml( XElement xml) {
			string plainXml = xml.ToString(SaveOptions.DisableFormatting);
      return plainXml;
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

  }
}