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
  public class InterfaceConfig {
    public string Name { get; set; }
    
    public bool IsDhcp { get; set; }
    public bool CreateDefaultRoute { get; set; }
    public bool UntaggedSub { get; set; } 
    
    public string AdminSpeed { get; set; }
    public string AdminDuplex { get; set; }
    public string AdminState { get; set; }
    
    public string Comment { get; set; }
    public string IpAddress { get; set; }
    public string MgmtProfile { get; set; }
    public string Tag { get; set; }
    public string Type { get; set; }
    public string NetflowProfile { get; set; }

    
    
    
    
    
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