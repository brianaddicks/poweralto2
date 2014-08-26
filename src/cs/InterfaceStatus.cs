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
  public class InterfaceStatus {
    public string Name { get; set; }
    
    public List<string> Services { get; set; }
    public string Vsys { get; set; }
    
    public decimal InBytes { get; set; }
    public decimal OutBytes { get; set; }
    public decimal InDrops { get; set; }
    public decimal InErrors { get; set; }
    
    public int Mtu { get; set; }
    public string VirtualRouter { get; set; }
    public int Tag { get; set; }
    public string Mode { get; set; }
    public string Zone { get; set; }
    public List<string> IpAddress { get; set; }
    
    public string MacAddress { get; set; }
    public string Speed { get; set; }
    public string Duplex { get; set; }
    
    
    
    
    
    
    /*
    public string ZoneType { get; set; } // validatset: tap, virtual wire layer2, layer3

    public List<string> Interfaces { get; set; } //changing an interface zone will be done from the interface object

    public string ZoneProtectionProfile { get; set; } //change to object once it's made
    public string LogSetting { get; set; } //change to object once it's made
    public bool EnableUserIdentification { get; set; }

    public List<string> UserIdAclInclude { get; set; }
    public List<string> UserIdAclExclude { get; set; }
    */
  }
}