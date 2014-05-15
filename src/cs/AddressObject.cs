using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace PowerAlto {
  public class AddressObject {
  	Validator Validator = new Validator();

    private string name;
    public string Name { get { return this.name; }
                         set { this.name = Validator.AlphaNum( value ); } }

    public string Description { get; set; }

    private string addressType;
    public string AddressType { get { return this.addressType; } }

    private string ipAddressMatch(string Input) {
      string ipAddressMaskPattern = @"^\d+\.\d+\.\d+\.\d+(\/\d{2})?$"; //need better validation
      Regex ipAddressMaskRx = new Regex( ipAddressMaskPattern );
      Match ipAddressMaskMatch = ipAddressMaskRx.Match( Input );

      string ipRangePattern = @"^\d+\.\d+\.\d+\.\d+\-\d+\.\d+\.\d+\.\d+$";
      Regex ipRangeRx = new Regex( ipRangePattern );
      Match ipRangeMatch = ipRangeRx.Match( Input );

      string fqdnPattern = @"^.+(\..+)+"; //needs better validation
      Regex fqdnRx = new Regex( fqdnPattern );
      Match fqdnMatch = fqdnRx.Match( Input );

      if ( ipAddressMaskMatch.Success ) {
        this.addressType = "ip-netmask";
        return Input;
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

    public List<string> Tags { get; set; }
  }
}