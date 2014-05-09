using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.Xml;
using System.Xml.Linq;
using System.Text.RegularExpressions;

namespace PowerAlto {
public class Zone {
    private string paNameMatch (string Name) {
      string namePattern =  @"^[a-zA-Z0-9\-_\.]+$";
      Regex nameRx = new Regex(namePattern);
      Match nameMatch = nameRx.Match(Name);
      if (nameMatch.Success) {
        return Name;
      } else {
        throw new System.ArgumentException("Value can only contain alphanumeric, hyphens, underscores, or periods.");
      }
    }

    private string name;
    public string Name { get { return this.name; }
                         set { this.name = paNameMatch( value ); } }
    
    public string ZoneType { get; set; } // validatset: tap, virtual wire layer2, layer3

    public List<string> Interfaces { get; set; } //changing an interface zone will be done from the interface object

    public string ZoneProtectionProfile { get; set; } //change to object once it's made
    public string LogSetting { get; set; } //change to object once it's made
    public bool EnableUserIdentification { get; set; }

    public List<string> UserIdAclInclude { get; set; }
    public List<string> UserIdAclExclude { get; set; }
  }
}