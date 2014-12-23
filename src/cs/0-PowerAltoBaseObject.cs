using System.Text.RegularExpressions;

namespace PowerAlto {

  public class PowerAltoBaseObject {
  
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
    
    protected XElement createXmlWithoutMembers( string XmlKeyword, string RuleProperty = null) {
			if (!(String.IsNullOrEmpty(RuleProperty))) {
				XElement nodeXml = new XElement(XmlKeyword,RuleProperty);
				return nodeXml;
			} else {
				return null;
			}
		}
    
    protected string printPlainXml( XElement xml) {
			string plainXml = xml.ToString(SaveOptions.DisableFormatting);
/*			string entryPattern = @"^<.+?>(.+)</entry>$";
			Regex entryRx = new Regex(entryPattern);
			Match entryMatch = entryRx.Match(plainXml);
      if (entryMatch.Success) {
        return entryMatch.Groups[1].Value;
      } else {
*/
        return plainXml;
//      }
		}
  }
}