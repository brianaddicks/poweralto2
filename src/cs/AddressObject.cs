using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Xml;

namespace PowerAlto {
  public class AddressObject : PowerAltoBaseObject {
  	//Validator Validator = new Validator();

    //private string name;
    public string Name { get; set; }
                         //set { this.name = Validator.AlphaNum( value ); } }

    public string Description { get; set; }

    List<string> validAddressTypes = new List<string>(new string[] {
			"ip-netmask",
			"ip-range",
			"fqdn",
		});
    
    private string addressType;
    public string AddressType {
			get {
				return this.addressType;
			}
      /*
			set {
				if ((validAddressTypes.FindIndex(x => x.Equals(value, StringComparison.OrdinalIgnoreCase) ) != -1) || String.IsNullOrEmpty(value)) {
					this.addressType = value;
				} else  {
					throw new ArgumentOutOfRangeException("Invalid value. Valid values are: " + string.Join(", ", validAddressTypes.ToArray()));
				}
			}*/
		}
		
    //private string addressType;
    //public string AddressType { get { return this.addressType; } }

    private string ipAddressMatch(string Input) {
      string ipAddressMaskPattern = @"^\d+\.\d+\.\d+\.\d+(\/\d{1,2})?$"; //need better validation
      Regex ipAddressMaskRx = new Regex( ipAddressMaskPattern );
      Match ipAddressMaskMatch = ipAddressMaskRx.Match( Input );

      string ipRangePattern = @"^\d+\.\d+\.\d+\.\d+\-\d+\.\d+\.\d+\.\d+$";
      Regex ipRangeRx = new Regex( ipRangePattern );
      Match ipRangeMatch = ipRangeRx.Match( Input );

      string fqdnPattern = @"^.+(\..+)+"; //needs better validation
      Regex fqdnRx = new Regex( fqdnPattern );
      Match fqdnMatch = fqdnRx.Match( Input );

      if ( ipAddressMaskMatch.Success ) {
        string maskCheck = @"\/\d{1,2}";
        Regex maskCheckRx = new Regex ( maskCheck );
        Match maskCheckMatch = maskCheckRx.Match ( Input );
        
        this.addressType = "ip-netmask";
        
        if ( maskCheckMatch.Success ) {
          return Input;
        } else {
          return Input + "/32";
        }
      }

      if ( ipRangeMatch.Success ) {
        this.addressType = "ip-range";
        return Input;
      }

      if ( fqdnMatch.Success ) {
        this.addressType = "fqdn";
        return Input;
      }

      throw new System.ArgumentException( "Does not match" );
    }

    private string address;
    public string Address {
      get { return this.address; }
      set { this.address = ipAddressMatch( value ); }
    }
    
    public string XPath {
      get {
        string baseXPath = "/config/devices/entry/vsys/entry/address";
        return baseXPath + "/entry[@name='" + this.Name + "']";
      }
    }
    
    public List<string> Tags { get; set; }
    
    //------------------------ CREATE XML --------------------------//
    
    public XElement Xml () {
                    
			// Create root
			XDocument XmlObject = new XDocument();
			
			// create entry nod and define name attribute
			XElement xmlEntry = new XElement("entry");
			xmlEntry.SetAttributeValue("name",this.Name);
			XmlObject.Add(xmlEntry);

			XmlObject.Element("entry").Add( createXmlWithoutMembers( this.addressType, this.address));	// Address
      XmlObject.Element("entry").Add( createXmlWithMembers( "tag", this.Tags, false ));			      // Tags
			XmlObject.Element("entry").Add( createXmlWithoutMembers( "description", this.Description));	// Description
			

			return XmlObject.Element("entry");
	  }

		public string PrintPrettyXml() {
			return Xml().ToString();
		}

		public string PrintPlainXml() {
			string plainXml = Xml().ToString(SaveOptions.DisableFormatting);
			string entryPattern = @"^<.+?>(.+)</entry>$";
			Regex entryRx = new Regex(entryPattern);
			Match entryMatch = entryRx.Match(plainXml);
			return entryMatch.Groups[1].Value;

//			return this.Xml().ToString(SaveOptions.DisableFormatting);

		}
  }
}