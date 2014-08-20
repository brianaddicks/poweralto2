###############################################################################
## Custom Objects Create in C-Sharp
###############################################################################

###############################################################################
# 0-Validator

Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location
	) -OutputAssembly C:\dev\poweralto2\helper.dll -OutputType Library -TypeDefinition @'
using System.Text.RegularExpressions;

namespace PowerAlto {

  public class Validator {
    public string AlphaNum (string Name) {
      string namePattern =  @"^[a-zA-Z0-9\-_\.]+$";
      Regex nameRx = new Regex(namePattern);
      Match nameMatch = nameRx.Match(Name);
      if (nameMatch.Success) {
        return Name;
      } else {
        throw new System.ArgumentException("Value can only contain alphanumeric, hyphens, underscores, or periods.");
      }
    }
  }
}
'@

[System.Reflection.Assembly]::LoadFile("C:\dev\poweralto2\helper.dll")

###############################################################################
# AddressObject

Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location,
    "C:\dev\poweralto2\helper.dll"
	) -TypeDefinition @'
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
'@

###############################################################################
# Interface

Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location,
    "C:\dev\poweralto2\helper.dll"
	) -TypeDefinition @'
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
public class Interface {
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
'@

###############################################################################
# InterfaceConfig

Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location,
    "C:\dev\poweralto2\helper.dll"
	) -TypeDefinition @'
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
'@

###############################################################################
# PaDevice

Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location,
    "C:\dev\poweralto2\helper.dll"
	) -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Xml;
using System.Web;

namespace PowerAlto {

    public class HttpQueryReturnObject {
        public HttpStatusCode Statuscode;
        public string DetailedError;
        public XmlDocument Data;
        public string RawData;
        public int HttpStatusCode {
            get {
                return (int)this.Statuscode;
            }
        }
    }

    public class PaDevice {
        // can we rewrite the helper functions as methods in this class?

        private DateTime clock;
        private Stack<string> urlhistory = new Stack<string>();
        private string poweraltoversion = "2.0";

        public string Device { get; set; }
        public int Port { get; set; }
        public string ApiKey { get; set; }
        public string Protocol { get; set; }

        public string Name { get; set; }
        public string Model { get; set; }
        public string Serial { get; set; }

        public string OsVersion { get; set; }
        public string GpAgent { get; set; }
        public string AppVersion { get; set; }
        public string ThreatVersion { get; set; }
        public string WildFireVersion { get; set; }
        public string UrlVersion { get; set; }
        public XmlDocument LastXmlResult { get; set; }

        public string ApiUrl {
            get {
                if ( !string.IsNullOrEmpty( this.Protocol ) && !string.IsNullOrEmpty( this.Device ) && this.Port > 0 ) {
                    return this.Protocol + "://" + this.Device + ":" + this.Port + "/api/";
                } else {
                    return null;
                }
            }
        }

        public string AuthString {
            get {
                if ( !string.IsNullOrEmpty( this.ApiKey ) ) {
                    return "key=" + this.ApiKey;
                } else {
                    return null;
                }
            }
        }


        public string PowerAltoVersion {
            get {
                return this.poweraltoversion;
            }
        }

        public string Clock {
            get {
                return this.clock.ToString();
            }
            set {
                this.clock = DateTime.Parse( value );
            }
        }
        public DateTime ClockasDateTime {
            get {
                return this.clock;
            }
            set {
                this.clock = value;
            }
        }

        public string[] UrlHistory {
            get {
                return this.urlhistory.ToArray();
            }
        }

        public void FlushHistory() {
            this.urlhistory.Clear();
        }


        public string UrlBuilder(string QueryString) {

            string[] Pieces = new string[5];
            Pieces[0] = this.ApiUrl;
            Pieces[1] = "?";
            Pieces[2] = this.AuthString;
            Pieces[3] = "&";
            Pieces[4] = QueryString;

            //if (QueryType == "op") {
            //  Pieces[5] += ("&cmd=" + Query);
            //}

            string CompletedString = string.Join( "", Pieces );

            this.urlhistory.Push( CompletedString );
            return CompletedString;
        }

        private static bool OnValidateCertificate(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors) {
            return true;
        }

        public void OverrideValidation() {
            ServicePointManager.ServerCertificateValidationCallback = OnValidateCertificate;
            ServicePointManager.Expect100Continue = true;
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3;
        }

        //Holds the raw result of the last query
        //Would like to convert this to emulate UrlHistory, but I think we need to get the HttpQuery helper as a method to PaDevice first

        private Stack<string> rawqueryhistory = new Stack<string>();

        public string[] RawQueryHistory {
            get {
                return this.rawqueryhistory.ToArray();
            }
        }

        public void FlushRawQueryHistory() {
            this.rawqueryhistory.Clear();
        }

        /*
        private Stack<XmlDocument> queryhistory = new Stack<XmlDocument>();

        public string[] QueryHistory {
          get {
            return this.queryhistory.ToArray();
          }
        }
    
        public void FlushQueryHistory () {
          this.queryhistory.Clear();
        }
        */

        public HttpQueryReturnObject HttpQuery(string Url, bool AsXml = true) {
            // this works. there's some logic missing from the original powershell version of this
            // that may or may not be important (it was error handling of some flavor)
            // also, all requests should not be treated as XML for this to be more generic
            // (the powershell version had an "-asxml" flag to handle this)

            HttpWebResponse Response = null;
            HttpStatusCode StatusCode = new HttpStatusCode();

            try {
                HttpWebRequest Request = WebRequest.Create( Url ) as HttpWebRequest;

                //if (Response.ContentLength > 0) {

                try {
                    Response = Request.GetResponse() as HttpWebResponse;
                    StatusCode = Response.StatusCode;
                } catch ( WebException we ) {
                    StatusCode = ( (HttpWebResponse)we.Response ).StatusCode;
                }

                string DetailedError = Response.GetResponseHeader( "X-Detailed-Error" );
                // }

            } catch {
                throw new HttpException( "httperror" );
            }

            if ( Response.StatusCode.ToString() == "OK" ) {
                StreamReader Reader = new StreamReader( Response.GetResponseStream() );
                string Result = Reader.ReadToEnd();
                XmlDocument XResult = new XmlDocument();

                if ( AsXml ) {
                    XResult.LoadXml( Result );
                }

                Reader.Close();
                Response.Close();

                HttpQueryReturnObject ReturnObject = new HttpQueryReturnObject();
                ReturnObject.Statuscode = StatusCode;
                if ( AsXml ) { ReturnObject.Data = XResult; }
                ReturnObject.RawData = Result;

                this.rawqueryhistory.Push( Result );
                //this.queryhistory.Push(XResult);

                return ReturnObject;

            } else {

                throw new HttpException( "httperror" );
            }
        }
    }
}
'@

###############################################################################
# SecurityRule

Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location,
    "C:\dev\poweralto2\helper.dll"
	) -TypeDefinition @'
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
	public class SecurityRule {

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

		public string Description { get; set; }
		public List<string> Tags { get; set; }
		
		public List<string> SourceZone { get; set; }
		public List<string> SourceAddress { get; set; }
		public bool SourceNegate { get; set; }
		
		public List<string> SourceUser { get; set; }
		public List<string> HipProfile { get; set; }
		
		public List<string> DestinationZone { get; set; }
		public List<string> DestinationAddress { get; set; }
		public bool DestinationNegate { get; set; }
		
		public List<string> Application { get; set; }
		
		public List<string> Service { get; set; }
		public List<string> UrlCategory { get; set; }
		
		public bool Allow { get; set; } //true = allow, false = deny
		
		private bool ProfileExists = false;
		
		private string setSecurityProfile ( string profileValue, string profileGroup = null ) {
			if (!(String.IsNullOrEmpty(profileGroup))) {
				throw new System.ArgumentException("Individual Security Profiles cannot be set with a Profile Group");
			} else {
				this.ProfileExists = true;
				return profileValue;
			}
		}

		private string profilegroup;
		public string ProfileGroup { get { return this.profilegroup; }
																 set { if (this.ProfileExists) {
																				 throw new System.ArgumentException("Profile Group cannot be set with individual profiles");
																			 } else {
																				 this.profilegroup = value;
																			 } } }		
		
		private string antivirusProfile;
		private string vulnerabilityProfile;
		private string antiSpywareProfile;
		private string urlFilteringProfile;
		private string fileBlockingProfile;
		private string dataFilteringProfile;

		public string AntivirusProfile { get { return this.antivirusProfile; }
																		 set { this.antivirusProfile = setSecurityProfile( value, this.ProfileGroup ); } }

		public string VulnerabilityProfile { get { return this.vulnerabilityProfile; }
			                                   set { this.vulnerabilityProfile = setSecurityProfile( value, this.ProfileGroup ); } }
		
		public string AntiSpywareProfile { get { return this.antiSpywareProfile; }
																		   set { this.antiSpywareProfile = setSecurityProfile( value, this.ProfileGroup ); } }

		public string UrlFilteringProfile { get { return this.urlFilteringProfile; }
																		 		set { this.urlFilteringProfile = setSecurityProfile( value, this.ProfileGroup ); } }

		public string FileBlockingProfile { get { return this.fileBlockingProfile; }
																		 		set { this.fileBlockingProfile = setSecurityProfile( value, this.ProfileGroup ); } }

		public string DataFilteringProfile { get { return this.dataFilteringProfile; }
																		 		 set { this.dataFilteringProfile = setSecurityProfile( value, this.ProfileGroup ); } }
		
		public bool LogAtSessionStart { get; set; }
		public bool LogAtSessionEnd { get; set; }
		public string LogForwarding { get; set; }
		
		public string Schedule { get; set; }

		private string qosType;
		public string QosType {
			get {
				return this.qosType;
			}
			set {
				if (String.IsNullOrEmpty( value ) ) {
					this.qosType = null;
					this.qosMarking = null;
				} else {
					string lowerValue = value.ToLower();
					this.qosType = lowerValue;
					if (lowerValue == "ip-dscp") {
						this.qosType = "ip-dscp";
					} else if (lowerValue == "ip-precedence") {
						if (validDscpOnlyMarkings.Contains( this.qosMarking ) ) {
							throw new ArgumentOutOfRangeException("Invalid QosMarking for QosType ip-precedence. Valid values are: " + string.Join(", ", validSharedQosMarkings.ToArray()));
						}
						this.qosType = "ip-precedence";
					} else {
						throw new ArgumentOutOfRangeException("Invalid value for QosType. Valid values are: ip-precedence, and ip-dscp");						
					}
				}
			}
		}

		List<string> validDscpOnlyMarkings = new List<string> (new string[] {
			"af11",
			"af12",
			"af13",
			"af21",
			"af22",
			"af23",
			"af31",
			"af32",
			"af33",
			"af41",
			"af42",
			"af43"
		} );

		List<string> validSharedQosMarkings = new List<string> (new string[] {
			"cs0",
			"cs1",
			"cs2",
			"cs3",
			"cs4",
			"cs5",
			"cs6",
			"cs7",
			"ef"
		} );

		private string qosMarking;
		public string QosMarking {
			get {
				return this.qosMarking;
			}
			set {
				if (String.IsNullOrEmpty(value)) {
					this.qosMarking = null;
					this.qosType = null;
				} else {
					string lowerValue = value.ToLower();
					if ( validDscpOnlyMarkings.Contains( lowerValue ) ) {
						if (this.QosType == "ip-precedence" ) {
							throw new ArgumentOutOfRangeException("Invalid value for ip-precedence. Valid values are: " + string.Join(", ", validSharedQosMarkings.ToArray()));
						}
						this.QosType = "ip-dscp";
						this.qosMarking = lowerValue;
					} else if ( validSharedQosMarkings.Contains( lowerValue) ) {
						this.qosMarking = lowerValue;
					} else {
						throw new ArgumentOutOfRangeException("Invalid value. Valid values are: " + string.Join(", ", validDscpOnlyMarkings.ToArray()) + "," + string.Join(", ", validSharedQosMarkings.ToArray()));
					}
				}
			}
		}
		
		public bool DisableSRI { get; set; }
		public bool Disabled { get; set; }

		public SecurityRule () {
			this.SourceAddress = new List<string> {"any"};
			this.SourceUser = new List<string> {"any"};
			this.HipProfile = new List<string> {"any"};
			this.DestinationAddress = new List<string> {"any"};
			this.Application = new List<string> {"application-default"};
			this.UrlCategory = new List<string> {"any"};
			this.Allow = true;
			this.LogAtSessionEnd = true;
		}
		
		public string LastUncommitedChangeBy { get; set; }
		public string LastUncommitedChangeTimestamp { get; set; }	// This should be a datetime object
		
		private XElement createXmlWithMembers( string XmlKeyword, List<string> RuleProperty = null, bool Required = false) {
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

		private XElement createXmlWithSingleMember( string XmlKeyword, string RuleProperty = null) {
			XElement nodeXml = new XElement(XmlKeyword);
			if (RuleProperty != null) {
				nodeXml.Add( new XElement( "member",RuleProperty ));
				return nodeXml;
			} else {
				return null;
			}
		}

		private XElement createXmlWithoutMembers( string XmlKeyword, string RuleProperty) {
			if (!(String.IsNullOrEmpty(RuleProperty))) {
				XElement nodeXml = new XElement(XmlKeyword,RuleProperty);
				return nodeXml;
			} else {
				return null;
			}
		}

		private XElement createXmlBool( string XmlKeyword, bool RuleProperty ) {
			XElement nodeXml = new XElement(XmlKeyword);
			if (RuleProperty) {
				nodeXml.Value = "yes";
			} else {
				nodeXml.Value = "no";
			}
			return nodeXml;
		}

		public XElement Xml () {
                    
			// Create root
			XDocument XmlObject = new XDocument();
			
			// create entry nod and define name attribute
			XElement xmlEntry = new XElement("entry");
			xmlEntry.SetAttributeValue("name",this.Name);
			XmlObject.Add(xmlEntry);

			// Set Disable Server Response Inspection

			XElement xmlDisableSRI = new XElement("option",
				createXmlBool( "disable-server-response-inspection", this.DisableSRI )
			);

			XmlObject.Element("entry").Add(xmlDisableSRI);

			// ---------------------------------------- Zones ----------------------------------------- //
			XmlObject.Element("entry").Add( createXmlWithMembers( "from", this.SourceZone, true ));			// Source Zones
			XmlObject.Element("entry").Add( createXmlWithMembers( "to", this.DestinationZone, true ));	// Destination Zones
			// ---------------------------------------------------------------------------------------- //

			// -------------------------------------------- Addresses --------------------------------------------- //
			XmlObject.Element("entry").Add( createXmlWithMembers( "source", this.SourceAddress, true ));						// Source Addresses
			XmlObject.Element("entry").Add( createXmlWithMembers( "destination", this.DestinationAddress, true ));	// Destination Address
			// ---------------------------------------------------------------------------------------------------- //

			XmlObject.Element("entry").Add( createXmlWithMembers( "source-user", this.SourceUser, true ));      // Source User
			XmlObject.Element("entry").Add( createXmlWithMembers( "category", this.UrlCategory, true ));       // Url Category
			XmlObject.Element("entry").Add( createXmlWithMembers( "application", this.Application, true ));    // Applications
			XmlObject.Element("entry").Add( createXmlWithMembers( "service", this.Service, true ));            // Services
			XmlObject.Element("entry").Add( createXmlWithMembers( "hip-profiles", this.HipProfile, true ));     // Hip Profiles

			// ----------------------------------- Action ----------------------------------- //
			XElement xmlAction = new XElement("action");
			if (this.Allow) { xmlAction.Value = "allow"; } 																		// Allow
			           else { xmlAction.Value = "deny";  }																		// Deny
			XmlObject.Element("entry").Add(xmlAction);
			// ------------------------------------------------------------------------------ //

			XmlObject.Element("entry").Add( createXmlBool( "log-start", this.LogAtSessionStart));				  				// Log At Start
			XmlObject.Element("entry").Add( createXmlBool( "log-end", this.LogAtSessionEnd));					  					// Log At End

			// ------------------------------------- Address Negation ------------------------------------- //
			XmlObject.Element("entry").Add( createXmlBool( "negate-source", this.SourceNegate ));			      // Source Negate
			XmlObject.Element("entry").Add( createXmlBool( "negate-destination", this.DestinationNegate ));	// Destination Negate
			// -------------------------------------------------------------------------------------------- //

			// ---------------------------------- Disabled ---------------------------------- //
			XmlObject.Element("entry").Add( createXmlBool( "disabled", this.Disabled));

			XmlObject.Element("entry").Add( createXmlWithoutMembers( "log-setting", this.LogForwarding));		  		// Log Forwarding
			XmlObject.Element("entry").Add( createXmlWithoutMembers( "schedule", this.Schedule));				  				// Schedule
			XmlObject.Element("entry").Add( createXmlWithMembers( "tag", this.Tags ));				            // Tags

			// Set Qos Marking
			if (!(String.IsNullOrEmpty(this.QosMarking)) && !(String.IsNullOrEmpty(this.QosType))) {
				XElement QosXml = new XElement("qos", new XElement( "marking" ));
				
				if (this.QosType == "ip-dscp") {
					XElement QosMarkingXml = new XElement("ip-dscp",this.QosMarking);
					QosXml.Element("marking").Add(QosMarkingXml);
				} else {
					XElement QosMarkingXml = new XElement("ip-precedence",this.QosMarking);
					QosXml.Element("marking").Add(QosMarkingXml);
				}
				
				XmlObject.Element("entry").Add(QosXml);
			}

			// ------------------------------ Security Profiles ----------------------------- //
			if (this.ProfileExists) {
				XElement xmlProfileSetting = new XElement("profile-setting",
					new XElement("profiles")
				);

				xmlProfileSetting.Element("profiles").Add( createXmlWithSingleMember( "virus", this.AntivirusProfile ));
				xmlProfileSetting.Element("profiles").Add( createXmlWithSingleMember( "spyware", this.AntiSpywareProfile ));
				xmlProfileSetting.Element("profiles").Add( createXmlWithSingleMember( "vulnerability", this.VulnerabilityProfile ));
				xmlProfileSetting.Element("profiles").Add( createXmlWithSingleMember( "url-filtering", this.UrlFilteringProfile ));
				xmlProfileSetting.Element("profiles").Add( createXmlWithSingleMember( "file-blocking", this.FileBlockingProfile ));
				xmlProfileSetting.Element("profiles").Add( createXmlWithSingleMember( "data-filtering", this.DataFilteringProfile ));

				XmlObject.Element("entry").Add(xmlProfileSetting);
			}

			if (!(String.IsNullOrEmpty(this.ProfileGroup))) {
				XElement xmlProfileSetting = new XElement("profile-setting");

				xmlProfileSetting.Add( createXmlWithSingleMember( "group", this.ProfileGroup ));

				XmlObject.Element("entry").Add(xmlProfileSetting);
			}
			// ------------------------------------------------------------------------------ //

			XmlObject.Element("entry").Add( createXmlWithoutMembers( "description", this.Description ));	// Description

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
		
		public string PrintCli () {
			List<string> CliList = new List<string>();
			
			// Start command and add name
			CliList.Add("set rulebase security rules ");
			CliList.Add(this.Name);
			
			// ---------------------------- Description and Tags ---------------------------- //
			CliList.Add(createCliWithoutMembers( "description", this.Description));		  	  	// Description
			CliList.Add(createCliWithMembers( "tag", this.Tags ));							  						// Tags
			// ------------------------------------------------------------------------------ //

			
			// --------------------------- Users and Hip Profiles --------------------------- //
			CliList.Add(createReqCliWithMembers( "source-user", this.SourceUser ));           // Source User
			CliList.Add(createReqCliWithMembers( "hip-profiles", this.HipProfile ));          // Hip Profiles
			// ------------------------------------------------------------------------------ //


			// ------------------------------ Address Negation ------------------------------ //
			CliList.Add(createCliBool( "negate-source", this.SourceNegate));				  				// Source Negate
			CliList.Add(createCliBool( "negate-destination", this.DestinationNegate));		  	// Destination Negate
			// ------------------------------------------------------------------------------ //


			// ----------------------------------- Zones ------------------------------------ //
			CliList.Add(createReqCliWithMembers( "from", this.SourceZone ));				  				// Source Zones
			CliList.Add(createReqCliWithMembers( "to", this.DestinationZone ));				  			// Destination Zones
			// ------------------------------------------------------------------------------ //


			// --------------------------------- Addresses ---------------------------------- //
			CliList.Add(createReqCliWithMembers( "source", this.SourceAddress ));						  // Source Addresses
			CliList.Add(createReqCliWithMembers( "destination", this.DestinationAddress ));	  // Destination Addresses
			// ------------------------------------------------------------------------------ //


			// ------------------ Applications, Services, and URL Category ------------------ //
			CliList.Add(createReqCliWithMembers( "application", this.Application ));          // Applications
			CliList.Add(createReqCliWithMembers( "service", this.Service ));                  // Services
			CliList.Add(createReqCliWithMembers( "category", this.UrlCategory ));             // Url Category
			// ------------------------------------------------------------------------------ //

			// ----------------------------------- Action ----------------------------------- //
			if (this.Allow) { CliList.Add(" action allow");	}                                 // Allow
			           else { CliList.Add(" action deny");  }                                 // Deny
			// ------------------------------------------------------------------------------ //


			// -------------------------------- Log Settings -------------------------------- //
			CliList.Add(createCliBool( "log-start", this.LogAtSessionStart));				  				// Log At Start
			CliList.Add(createCliBool( "log-end", this.LogAtSessionEnd));					  					// Log At End
			CliList.Add(createCliWithoutMembers( "log-setting", this.LogForwarding));		  		// Log Forwarding
			// ------------------------------------------------------------------------------ //


			// ----------------------------- Schedule and DSRI ------------------------------ //
			CliList.Add(createCliWithoutMembers( "schedule", this.Schedule));				  				// Schedule
			string cmdDisableSRI = "option disable-server-response-inspection";
			CliList.Add(createCliBool( cmdDisableSRI, this.DisableSRI));										  // Disable SRI
			// ------------------------------------------------------------------------------ //


			// ------------------------------ Security Profiles ----------------------------- //
			if (this.ProfileExists) {
				CliList.Add(" profile-setting profiles");
				CliList.Add(createCliWithoutMembers( "virus", this.AntivirusProfile ));
				CliList.Add(createCliWithoutMembers( "spyware", this.AntiSpywareProfile ));
				CliList.Add(createCliWithoutMembers( "vulnerability", this.VulnerabilityProfile ));
				CliList.Add(createCliWithoutMembers( "url-filtering", this.UrlFilteringProfile ));
				CliList.Add(createCliWithoutMembers( "file-blocking", this.FileBlockingProfile ));
				CliList.Add(createCliWithoutMembers( "data-filtering", this.DataFilteringProfile ));
			}

			if (!(String.IsNullOrEmpty(this.ProfileGroup))) {
				CliList.Add(" profile-settings group ");
				CliList.Add(this.ProfileGroup);
			}			
			// ------------------------------------------------------------------------------ //


			// -------------------------------- QoS Settings -------------------------------- //
			if (!(String.IsNullOrEmpty(this.QosType)) && !(String.IsNullOrEmpty(this.QosMarking))) {
				string cliQos = " qos marking " + this.QosType + " " + this.QosMarking;
				CliList.Add(cliQos);
			}
			// ------------------------------------------------------------------------------ //			
			
			string CliString = string.Join("",CliList.ToArray());  // Smash it all together
			return CliString;
		}
		
		private string createCliWithoutMembers( string CliKeyword, string RuleProperty) {
			string CliObject = "";
			if (RuleProperty != null) {
				CliObject += " " + CliKeyword + " " + RuleProperty;
			}
			return CliObject;
		}

		private string createReqCliWithMembers( string CliKeyword, List<string> RuleProperty = null) {
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

		private string createCliWithMembers( string CliKeyword, List<string> RuleProperty = null) {
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

		private string createCliBool( string CliKeyword, bool RuleProperty ) {
			string CliObject = "";
			if (RuleProperty) {
				CliObject += " " + CliKeyword + " yes";
			} else {
				CliObject += " " + CliKeyword + " no";
			}
			return CliObject;
		}
	}
}
'@

###############################################################################
# Service

Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location,
    "C:\dev\poweralto2\helper.dll"
	) -TypeDefinition @'
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
	public class Service {

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

		public string Description { get; set; }

		private string protocol;
		public string Protocol { get { return this.protocol; }
														 set { string protocolPattern = @"^(udp|tcp)$";
														 			 //Regex protocolRx = new Regex(protocolPattern);
														 			 Match protocolMatch = Regex.Match( value, protocolPattern, RegexOptions.IgnoreCase);
														 			 if (protocolMatch.Success) {
														 			 	 this.protocol = value.ToLower();
														 			 } else {
														 			 	 throw new System.ArgumentException("Protocol must be udp or tcp.");
														 			 } } }

		//Should probably add some more valiation for port ranges, ie: the second number in a range should be higher than the first.
		private string paPortMatch (string Port) {
			string portPattern = @"^(\d+(\-|\,)\d+|\d+)+$";
			Regex portRx = new Regex(portPattern);
			Match portMatch = portRx.Match(Port);
			if (portMatch.Success) {
				return Port;
			} else {
				throw new System.ArgumentException("Port can be a single port #, range (1-65535), comma separated (80,8080,443), or a combination of the three.");
			}
		}

		private string destinationPort;
		public string DestinationPort { get { return this.destinationPort; }
																		set { this.destinationPort = paPortMatch( value ); } }

		private string sourcePort;
		public string SourcePort { get { return this.sourcePort; }
															 set { this.sourcePort = paPortMatch( value ); } }

		public string Tags { get; set; }
	}
}
'@

###############################################################################
# Zone

Add-Type -ReferencedAssemblies @(
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Web")).Location,
	([System.Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq")).Location,
    "C:\dev\poweralto2\helper.dll"
	) -TypeDefinition @'
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
'@

###############################################################################
## Start Powershell Cmdlets
###############################################################################

###############################################################################
# Get-PaAddressObject

function Get-PaAddressObject {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $Xpath = "/config/devices/entry/vsys/entry/address"

    if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."
    Write-Debug $ResponseData

    if ($ResponseData.address) { $ResponseData = $ResponseData.address.entry } `
                       else { $ResponseData = $ResponseData.entry             }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.AddressObject
        Write-Verbose "Creating new AddressObject"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting Address Name $($r.name)"
        
        if ($r.'ip-netmask') {
        #    $ResponseObject.AddressType = 'ip-netmask'
            $ResponseObject.Address = $r.'ip-netmask'
            Write-Verbose "Setting Address: ip-netmask/$($r.'ip-netmask')"
        }

        if ($r.'ip-range') {
        #    $ResponseObject.AddressType = 'ip-range'
            $ResponseObject.Address = $r.'ip-range'
            Write-Verbose "Setting Address: ip-range/$($r.'ip-range')"
        }

        if ($r.fqdn) {
        #    $ResponseObject.AddressType = 'fqdn'
            $ResponseObject.Address = $r.fqdn
            Write-Verbose "Setting Address: fqdn/$($r.fqdn)"
        }

        $ResponseObject.Tags = HelperGetPropertyMembers $r tag
        $ResponseObject.Description = $r.description


        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaConfig

function Get-PaConfig {
	Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Xpath = "/config",

        [Parameter(Mandatory=$False,Position=1)]
        [ValidateSet("get","show")]
        [string]$Action = "show"
    )

    HelperCheckPaConnection

    $QueryTable = @{ type   = "config"
                     xpath  = $Xpath
                     action = $Action  }
    
    $QueryString = HelperCreateQueryString $QueryTable
    $Url         = $global:PaDeviceObject.UrlBuilder($QueryString)
    $Response    = $global:PaDeviceObject.HttpQuery($url)

    return HelperCheckPaError $Response
}

###############################################################################
# Get-PaDevice

function Get-PaDevice {
	<#
	.SYNOPSIS
		Establishes initial connection to Palo Alto API.
		
	.DESCRIPTION
		The Get-PaDevice cmdlet establishes and validates connection parameters to allow further communications to the Palo Alto API. The cmdlet needs at least two parameters:
		 - The device IP address or FQDN
		 - A valid API key
		
		
		The cmdlet returns an object containing details of the connection, but this can be discarded or saved as desired; the returned object is not necessary to provide to further calls to the API.
	
	.EXAMPLE
		Get-PaDevice "pa.example.com" "LUFRPT1PR2JtSDl5M2tjTktBeTkyaGZMTURTTU9BZm89OFA0Rk1WMS8zZGtKN0F"
		
		Connects to PRTG using the default port (443) over SSL (HTTPS) using the username "jsmith" and the passhash 1234567890.
		
	.EXAMPLE
		Get-PrtgServer "prtg.company.com" "jsmith" 1234567890 -HttpOnly
		
		Connects to PRTG using the default port (80) over SSL (HTTP) using the username "jsmith" and the passhash 1234567890.
		
	.EXAMPLE
		Get-PrtgServer -Server "monitoring.domain.local" -UserName "prtgadmin" -PassHash 1234567890 -Port 8080 -HttpOnly
		
		Connects to PRTG using port 8080 over HTTP using the username "prtgadmin" and the passhash 1234567890.
		
	.PARAMETER Server
		Fully-qualified domain name for the PRTG server. Don't include the protocol part ("https://" or "http://").
		
	.PARAMETER UserName
		PRTG username to use for authentication to the API.
		
	.PARAMETER PassHash
		PassHash for the PRTG username. This can be retrieved from the PRTG user's "My Account" page.
	
	.PARAMETER Port
		The port that PRTG is running on. This defaults to port 443 over HTTPS, and port 80 over HTTP.
	
	.PARAMETER HttpOnly
		When specified, configures the API connection to run over HTTP rather than the default HTTPS.
		
	.PARAMETER Quiet
		When specified, the cmdlet returns nothing on success.
	#>

	Param (
		[Parameter(Mandatory=$True,Position=0)]
		[ValidatePattern("\d+\.\d+\.\d+\.\d+|(\w\.)+\w")]
		[string]$Device,

        [Parameter(ParameterSetName="keyonly",Mandatory=$True,Position=1)]
        [string]$ApiKey,

        [Parameter(ParameterSetName="credential",Mandatory=$True,Position=1)]
        [pscredential]$PaCred,

		[Parameter(Mandatory=$False,Position=2)]
		[int]$Port = $null,

		[Parameter(Mandatory=$False)]
		[alias('http')]
		[switch]$HttpOnly,
		
		[Parameter(Mandatory=$False)]
		[alias('q')]
		[switch]$Quiet
	)

    BEGIN {

		if ($HttpOnly) {
			$Protocol = "http"
			if (!$Port) { $Port = 80 }
		} else {
			$Protocol = "https"
			if (!$Port) { $Port = 443 }
			
			$PaDeviceObject = New-Object Poweralto.PaDevice
			
			$PaDeviceObject.Protocol = $Protocol
			$PaDeviceObject.Port     = $Port
			$PaDeviceObject.Device   = $Device

            if ($ApiKey) {
                $PaDeviceObject.ApiKey = $ApiKey
            } else {
                $UserName = $PaCred.UserName
                $Password = $PaCred.getnetworkcredential().password
            }
			
			$PaDeviceObject.OverrideValidation()
		}
    }

    PROCESS {
        
        $QueryStringTable = @{ type = "op"
                               cmd  = "<show><system><info></info></system></show>" }

        $QueryString = HelperCreateQueryString $QueryStringTable
		$url         = $PaDeviceObject.UrlBuilder($QueryString)

		try   { $QueryObject = $PaDeviceObject.HttpQuery($url) } `
        catch {	throw "Error performing HTTP query"	           }

        $Data = HelperCheckPaError $QueryObject
		$Data = $Data.system

        $PaDeviceObject.Name            = $Data.hostname
        $PaDeviceObject.Model           = $Data.model
        $PaDeviceObject.Serial          = $Data.serial
        $PaDeviceObject.OsVersion       = $Data.'sw-version'
        $PaDeviceObject.GpAgent         = $Data.'global-protect-client-package-version'
        $PaDeviceObject.AppVersion      = $Data.'app-version'
        $PaDeviceObject.ThreatVersion   = $Data.'threat-version'
        $PaDeviceObject.WildFireVersion = $Data.'wildfire-version'
        $PaDeviceObject.UrlVersion      = $Data.'url-filtering-version'

        $global:PaDeviceObject = $PaDeviceObject

		
		if (!$Quiet) {
			return $PaDeviceObject | Select-Object @{n='Connection';e={$_.ApiUrl}},Name,OsVersion
		}
    }
}

###############################################################################
# Get-PaInterface

function Get-PaInterface {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [ValidatePattern("\d+\.\d+\.\d+\.\d+|(\w\.)+\w")]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $ElementName = "network/interface"
    $Xpath = "/config/devices/entry/$ElementName"
    $InterfaceTypeRx = [regex] '(?<type>loopback|vlan|tunnel|ethernet)(?<num>\d+\/\d+|\.\d+)?(?<sub>\.\d+)?'

    if ($Name) {
        $InterfaceMatch = $InterfaceTypeRx.Match($Name)
        $InterfaceType  = $InterfaceMatch.Groups['type'].Value

        Write-Verbose $InterfaceMatch.Value

        switch ($InterfaceType) {
            { ($_ -eq "loopback") -or 
              ($_ -eq "tunnel") } {
                if ($InterfaceMatch.Groups['num'].Success) {
                    $Xpath += "/$InterfaceType/units/entry[@name='$Name']"
                } else {
                    $Xpath += "/$Name"
                }
            }
            ethernet {
                $Xpath += "/$InterfaceType/entry[@name='$($InterfaceMatch.Groups['type'].Value)$($InterfaceMatch.Groups['num'].Value)']"
                if ($InterfaceMatch.Groups['sub'].Success) {
                    $Xpath += "/layer3/units/entry[@name='$Name']"
                }
            }
            default {
                $Xpath += "/$InterfaceType/entry[@name='$Name']"
            }
        }
    }

    Write-Verbose $Xpath

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."
    $Global:test = $ResponseData

    if ($Name) {
        $InterfaceObject             = New-Object PowerAlto.Interface
        $InterfaceObject.Name        = $Name
        $InterfaceObject.Comment     = $ResponseData.entry.comment
        $InterfaceObject.MgmtProfile = $ResponseData.entry.'interface-management-profile'
        $InterfaceObject.IpAddress   = $ResponseData.entry.ip.entry.name
        $InterfaceObject.Tag         = $ResponseData.entry.tag

        if ($ResponseData.entry.layer3) {
            $InterfaceObject.Type = 'layer3'
            $Entry = $ResponseData.entry

            if ($Entry.layer3.'dhcp-client'.enable -eq 'yes') {
                $InterfaceObject.IsDhcp = $true
            }

            if ($Entry.layer3.'dhcp-client'.'create-default-route' -eq 'yes') {
                $InterfaceObject.CreateDefaultRoute = $true
            }

            $InterfaceObject.AdminSpeed     = $Entry.'link-speed'
            $InterfaceObject.AdminDuplex    = $Entry.'link-duplex'
            $InterfaceObject.AdminState     = $Entry.'link-state'
            $InterfaceObject.IpAddress      = $Entry.layer3.ip.entry.name
            $InterfaceObject.NetflowProfile = $Entry.layer3.'netflow-profile'
            $InterfaceObject.MgmtProfile    = $Entry.layer3.'interface-management-profile'

            if ($Entry.layer3.'untagged-sub-interface' -eq 'yes') {
                $InterfaceObject.UntaggedSub = $true
            }

        }

        return $InterfaceObject
    }


    <#
    if ($ResponseData.$ElementName) { $ResponseData = $ResponseData.$ElementName.entry } `
                               else { $ResponseData = $ResponseData.entry             }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.Service
        Write-Verbose "Creating new Service object"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting Service Name $($r.name)"
        
        $Protocol = ($r.protocol | gm -Type Property).Name

        $ResponseObject.Protocol        = $Protocol
        $ResponseObject.DestinationPort = $r.protocol.$Protocol.port

        if ($r.protocol.$Protocol.'source-port') { $ResponseObject.SourcePort      = $r.protocol.$Protocol.'source-port' }

        $ResponseObject.Tags            = HelperGetPropertyMembers $r tag
        $ResponseObject.Description     = $r.description


        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }
    
    return $ResponseTable#>
}

###############################################################################
# Get-PaInterfaceConfig

function Get-PaInterfaceConfig {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        #[ValidatePattern("\w+|(\w\.)+\w")]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ElementName = "network/interface"
    $Xpath = "/config/devices/entry/$ElementName"
    $InterfaceTypeRx = [regex] '(?<type>loopback|vlan|tunnel|ethernet)(?<num>\d+\/\d+|\.\d+)?(?<sub>\.\d+)?'

    if ($Name) {
        $InterfaceMatch = $InterfaceTypeRx.Match($Name)
        $InterfaceType  = $InterfaceMatch.Groups['type'].Value

        Write-Verbose $InterfaceMatch.Value

        switch ($InterfaceType) {
            { ($_ -eq "loopback") -or
              ($_ -eq "vlan") -or
              ($_ -eq "tunnel") } {
                if ($InterfaceMatch.Groups['num'].Success) {
                    $Xpath += "/$InterfaceType/units/entry[@name='$Name']"
                } else {
                    $Xpath += "/$Name"
                }
            }
            ethernet {
                $Xpath += "/$InterfaceType/entry[@name='$($InterfaceMatch.Groups['type'].Value)$($InterfaceMatch.Groups['num'].Value)']"
                if ($InterfaceMatch.Groups['sub'].Success) {
                    $Xpath += "/layer3/units/entry[@name='$Name']"
                }
            }
            default {
                $Xpath += "/$InterfaceType/entry[@name='$Name']"
            }
        }
    }

    Write-Verbose $Xpath

    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."
    $Global:test = $ResponseData

    function ProcessInterface ($entry) {
        $interfaceObject             = New-Object PowerAlto.InterfaceConfig
        $interfaceObject.Name        = $entry.name
        $interfaceObject.Comment     = $entry.comment
        $InterfaceObject.AdminSpeed  = $Entry.'link-speed'
        $InterfaceObject.AdminDuplex = $Entry.'link-duplex'
        $InterfaceObject.AdminState  = $Entry.'link-state'

        if ($entry.layer3 -or ($entry.firstchild.name -eq 'tap')) {
            $interfaceObject.MgmtProfile    = $entry.layer3.'interface-management-profile'
            $interfaceObject.NetflowProfile = $entry.layer3.'netflow-profile'
            $interfaceObject.IpAddress      = $entry.layer3.ip.entry.name

            if ($entry.layer3) {
                $interfaceObject.Type = 'layer3'
            } elseif ($entry.firstchild.name -eq 'tap') {
                $interfaceObject.Type = 'tap'
            }

            if ($entry.layer3.'untagged-sub-interface' -eq 'yes') {
                $interfaceObject.UntaggedSub = $true
            }

            if ($entry.layer3.'dhcp-client'.enable -eq 'yes') {
                $interfaceObject.IsDhcp = $true

                if ($entry.layer3.'dhcp-client'.'create-default-route' -eq 'yes') {
                    $interfaceObject.CreateDefaultRoute = $true
                }
            }
        } elseif ($entry.ip.entry.name) {
            $interfaceObject.MgmtProfile = $entry.'interface-management-profile'
            $interfaceObject.IpAddress   = $entry.ip.entry.name
            $interfaceObject.Tag         = $entry.tag

            switch ($entry.name) {
                { $_ -match 'ethernet' } {
                    $interfaceObject.Type = 'subinterface'
                }
            }
        }

        return $interfaceObject
    }


    ###############################################################################
    # Process Response

    if ($Name) {
        if ($ResponseData.entry) {
            ProcessInterface $ResponseData.entry
        } else {
            ProcessInterface $ResponseData.$Name
        }

        return $InterfaceObject
    } else {
        $InterfaceObjects = @()

        ###############################################################################
        # Ethernet Interfaces

        Write-Verbose '## Ethernet Interfaces ##'
        foreach ($e in $ResponseData.interface.ethernet.entry) {
            if ($e.layer3 -or ($e.firstchild.name -eq 'tap')) {
                Write-Verbose $e.name
                $InterfaceObjects += ProcessInterface $e
                if ($e.layer3.units) {
                    foreach ($u in $e.layer3.units.entry) {
                        Write-Verbose $u.name
                        $InterfaceObjects += ProcessInterface $u
                    }
                }
            }
        }

        ###############################################################################
        # Loopback Interfaces

        Write-Verbose '## Loopback Interfaces ##'
        foreach ($e in $ResponseData.interface.loopback) {
            Write-Verbose 'loopback'
            $InterfaceObjects += ProcessInterface $e
            if ($e.units) {
                foreach ($u in $e.units.entry) {
                    Write-Verbose $u.name
                    $InterfaceObjects += ProcessInterface $u
                }
            }
        }

        ###############################################################################
        # Vlan Interfaces

        Write-Verbose '## Vlan Interfaces ##'
        foreach ($e in $ResponseData.interface.vlan) {
            $InterfaceObjects += ProcessInterface $e
            Write-Verbose 'vlan'
            if ($e.units) {
                foreach ($u in $e.units.entry) {
                    Write-Verbose $u.name
                    $InterfaceObjects += ProcessInterface $u
                }
            }
        }

        ###############################################################################
        # Tunnel Interfaces

        Write-Verbose '## Tunnel Interfaces ##'
        foreach ($e in $ResponseData.interface.tunnel) {
            Write-Verbose "tunnel"
            $InterfaceObjects += ProcessInterface $e
            if ($e.units) {
                foreach ($u in $e.units.entry) {
                    Write-Verbose $u.name
                    $InterfaceObjects += ProcessInterface $u
                }
            }
        }
        
        return $InterfaceObjects
    }
}

###############################################################################
# Get-PaSecurityRule

function Get-PaSecurityRule {
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $Xpath = "/config/devices/entry/vsys/entry/rulebase/security/rules"

    if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $RuleData = Get-PaConfig -Xpath $Xpath -Action $Action

    if ($RuleData.rules) { $RuleData = $RuleData.rules.entry } `
                    else { $RuleData = $RuleData.entry       }
        

    $RuleTable = @()
    foreach ($r in $RuleData) {
        $RuleObject = New-Object PowerAlto.SecurityRule

        # General
        $RuleObject.Name        = $r.Name
        $RuleObject.Description = $r.Description
        $RuleObject.Tags        = HelperGetPropertyMembers $r tag

        # Source
        $RuleObject.SourceZone    = HelperGetPropertyMembers $r from
        $RuleObject.SourceAddress = HelperGetPropertyMembers $r source
        if ($r.'negate-source' -eq 'yes') { $RuleObject.SourceNegate = $true }

        # User
        $RuleObject.SourceUser = HelperGetPropertyMembers $r source-user
        $RuleObject.HipProfile = HelperGetPropertyMembers $r hip-profiles

        # Destination
        $RuleObject.DestinationZone    = HelperGetPropertyMembers $r to
        $RuleObject.DestinationAddress = HelperGetPropertyMembers $r destination
        if ($r.'negate-destination' -eq 'yes') { $RuleObject.DestinationNegate = $true }

        # Application
        $RuleObject.Application = HelperGetPropertyMembers $r application

        # Service / Url Category
        $RuleObject.UrlCategory = HelperGetPropertyMembers $r category
        $RuleObject.Service     = HelperGetPropertyMembers $r service

        # Action Setting
        if ($r.action -eq 'allow') { $RuleObject.Allow = $true }

        # Profile Setting
        $ProfileSetting = $r.'profile-setting'
        if ($ProfileSetting.profiles) {
            $RuleObject.AntivirusProfile     = $ProfileSetting.profiles.virus.member
            $RuleObject.AntiSpywareProfile   = $ProfileSetting.profiles.spyware.member
            $RuleObject.VulnerabilityProfile = $ProfileSetting.profiles.vulnerability.member
            $RuleObject.UrlFilteringProfile  = $ProfileSetting.profiles.'url-filtering'.member
            $RuleObject.FileBlockingProfile  = $ProfileSetting.profiles.'file-blocking'.member
            $RuleObject.DataFilteringProfile = $ProfileSetting.profiles.'data-filtering'.member
        } elseif ($ProfileSetting.group) {
            if ($ProfileSetting.group.member) { $RuleObject.ProfileGroup = $ProfileSetting.group.member }
        }

        # Log Setting
        if ($r.'log-start' -eq 'yes') { $RuleObject.LogAtSessionStart = $true }
        if ($r.'log-end' -eq 'yes')   { $RuleObject.LogAtSessionEnd = $true   }
        $RuleObject.LogForwarding = $r.'log-setting'

        # QoS Settings
        $QosSetting = $r.qos.marking
        if ($QosSetting.'ip-precedence') {
            $RuleObject.QosType    = "IpPrecedence"
            $RuleObject.QosMarking = $QosSetting.'ip-precedence'
        } elseif ($QosSetting.'ip-dscp') {
            $RuleObject.QosType    = "IpDscp"
            $RuleObject.QosMarking = $QosSetting.'ip-dscp'
        }

        # Other Settings
        $RuleObject.Schedule = $r.schedule
        if ($r.option.'disable-server-response-inspection' -eq 'yes') { $RuleObject.DisableSRI = $true }
        if ($r.disabled -eq 'yes') { $RuleObject.Disabled = $true }

        $RuleTable += $RuleObject
    }

    return $RuleTable

}

###############################################################################
# Get-PaService

function Get-PaService {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$False,Position=0)]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $ElementName = "service"
    $Xpath = "/config/devices/entry/vsys/entry/$ElementName"

    if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ResponseData = Get-PaConfig -Xpath $Xpath -Action $Action

    Write-Verbose "Pulling configuration information from $($global:PaDeviceObject.Name)."
    Write-Debug $ResponseData

    if ($ResponseData.$ElementName) { $ResponseData = $ResponseData.$ElementName.entry } `
                               else { $ResponseData = $ResponseData.entry             }

    $ResponseTable = @()
    foreach ($r in $ResponseData) {
        $ResponseObject = New-Object PowerAlto.Service
        Write-Verbose "Creating new Service object"
        
        $ResponseObject.Name = $r.name
        Write-Verbose "Setting Service Name $($r.name)"
        
        $Protocol = ($r.protocol | gm -Type Property).Name

        $ResponseObject.Protocol        = $Protocol
        $ResponseObject.DestinationPort = $r.protocol.$Protocol.port

        if ($r.protocol.$Protocol.'source-port') { $ResponseObject.SourcePort      = $r.protocol.$Protocol.'source-port' }

        $ResponseObject.Tags            = HelperGetPropertyMembers $r tag
        $ResponseObject.Description     = $r.description


        $ResponseTable += $ResponseObject
        Write-Verbose "Adding object to array"
    }
    
    return $ResponseTable
}

###############################################################################
# Get-PaZone

function Get-PaZone {
    Param (
		[Parameter(Mandatory=$False,Position=0)]
		[string]$Name,

        [Parameter(Mandatory=$False)]
        [switch]$Candidate
    )

    $Xpath = "/config/devices/entry/vsys/entry/zone"

    if ($Name) { $Xpath += "/entry[@name='$Name']" }

    if ($Candidate) { $Action = "get"; Throw "not supported yet"  } `
               else { $Action = "show" }
    
    $ZoneData = Get-PaConfig -Xpath $Xpath -Action $Action

    if ($ZoneData.zone) { $ZoneData = $ZoneData.zone.entry } `
                   else { $ZoneData = $ZoneData.entry      }
        

    $ZoneTable = @()
    foreach ($z in $ZoneData) {
        $ZoneObject = New-Object PowerAlto.Zone

        $ZoneObject.Name                  = $z.name
        $ZoneObject.LogSetting            = $z.network.'log-setting'
        $ZoneObject.ZoneProtectionProfile = $z.network.'zone-protection-profile'
        $ZoneObject.UserIdAclInclude      = $z.'user-acl'.'include-list'.member
        $ZoneObject.UserIdAclExclude      = $z.'user-acl'.'exclude-list'.member

        if ($z.'enable-user-identification') {
            $ZoneObject.EnableUserIdentification = $true
        }


        $IsLayer3 = $z.network.layer3
        if ($IsLayer3) {
            $ZoneObject.ZoneType = "layer3"
            $ZoneObject.Interfaces = $IsLayer3.member
        }

        $ZoneTable += $ZoneObject
    }

    return $ZoneTable

}

###############################################################################
# Set-PaConfig

function Set-PaConfig {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Xpath = "/config",

        [Parameter(Mandatory=$True,Position=1)]
        [ValidateSet("set")]
        [string]$Action,

        [Parameter(Mandatory=$True,Position=2)]
        [string]$Element
    )

    HelperCheckPaConnection

    $QueryTable = @{ type    = "config"
                     xpath   = $Xpath
                     action  = $Action
                     element = $Element }
    
    Write-Debug "xpath: $Xpath"
    Write-Debug "action: $Action"
    Write-Debug "element: $Element"

    $QueryString = HelperCreateQueryString $QueryTable
    Write-Debug $QueryString
    $Url         = $PaDeviceObject.UrlBuilder($QueryString)
    Write-Debug $Url
    $Response    = HelperHttpQuery $Url -AsXML

    return HelperCheckPaError $Response
}

###############################################################################
# Set-PaSecurityRule

function Set-PaSecurityRule {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)]
        [string]$Name
    )

    $Xpath  = "/config/devices/entry/vsys/entry/rulebase/security"
    $Xpath += "/entry[@name=`'$Name`'`]"

    $Action = "set"

    $ElementObject = New-Object Poweralto.SecurityRule

    $ElementObject.Name = $Name
    Write-Debug

    $ResponseData = Set-PaConfig -Xpath $Xpath -Action $Action -Element $ElementObject.PrintPlainXml() -Debug
}

###############################################################################
## Start Helper Functions
###############################################################################

###############################################################################
# HelperCheckPaConnection

function HelperCheckPaConnection {
    if (!($Global:PaDeviceObject)) {
        Throw "Not connected to any Palo Alto Devices."
    }
}

###############################################################################
# HelperCheckPaError

function HelperCheckPaError {
    [CmdletBinding()]
	Param (
	    [Parameter(Mandatory=$True,Position=0)]
	    $Response
    )

    $Status = $Response.data.response.status
    Write-Verbose $Status
    if ($Status -eq "error") {
        if ($Response.data.response.code) {
            $ErrorMessage  = "Error Code $($Response.data.response.code): "
            $ErrorMessage += $Response.data.response.result.msg
        } elseif ($Response.data.response.msg.line) {
            Write-Verbose "Line is: $($Response.data.response.msg.line)"
            $ErrorMessage = $Response.data.response.msg.line
        } else {
            Write-Verbose "Message: $($Response.data.response.msg.line)"
            $ErrorMessage = $Response.data.response.msg
        }
        Throw "$ErrorMessage`."
    } else {
        return $Response.data.response.result
    }
}

###############################################################################
# HelperCreateQueryString

function HelperCreateQueryString {
    Param (
        [Parameter(Mandatory=$True,Position=0)]
		[hashtable]$QueryTable
    )

    $QueryString = [System.Web.httputility]::ParseQueryString("")

    foreach ($Pair in $QueryTable.GetEnumerator()) {
	    $QueryString[$($Pair.Name)] = $($Pair.Value)
    }

    return $QueryString.ToString()
}

###############################################################################
# HelperGetPropertyMembers

function HelperGetPropertyMembers {
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        $XmlObject,

        [Parameter(Mandatory=$True,Position=1)]
        [string]$XmlProperty
    )

    $ReturnObject = @()
    
    if ($XmlObject.$XmlProperty) {
        foreach ($x in $XmlObject.$XmlProperty.member) { $ReturnObject += $x }
    }

    return $ReturnObject
}

###############################################################################
# HelperHttpQuery

function HelperHTTPQuery {
	Param (
		[Parameter(Mandatory=$True,Position=0)]
		[string]$URL,

		[Parameter(Mandatory=$False)]
		[alias('xml')]
		[switch]$AsXML
	)

	try {
		$Response = $null
		$Request = [System.Net.HttpWebRequest]::Create($URL)
		$Response = $Request.GetResponse()
		if ($Response) {
			$StatusCode = $Response.StatusCode.value__
			$DetailedError = $Response.GetResponseHeader("X-Detailed-Error")
		}
	}
	catch {
		$ErrorMessage = $Error[0].Exception.ErrorRecord.Exception.Message
		$Matched = ($ErrorMessage -match '[0-9]{3}')
		if ($Matched) {
			throw ('HTTP status code was {0} ({1})' -f $HttpStatusCode, $matches[0])
		}
		else {
			throw $ErrorMessage
		}

		#$Response = $Error[0].Exception.InnerException.Response
		#$Response.GetResponseHeader("X-Detailed-Error")
	}

	if ($Response.StatusCode -eq "OK") {
		$Stream    = $Response.GetResponseStream()
		$Reader    = New-Object IO.StreamReader($Stream)
		$FullPage  = $Reader.ReadToEnd()

		if ($AsXML) {
			$Data = [xml]$FullPage
            if ($Global:PaDeviceObject) { $Global:PaDeviceObject.LastXmlResult = $Data }
		} else {
			$Data = $FullPage
		}

		$Global:LastResponse = $Data

		$Reader.Close()
		$Stream.Close()
		$Response.Close()
	} else {
		Throw "Error Accessing Page $FullPage"
	}

	$ReturnObject = "" | Select-Object StatusCode,DetailedError,Data
	$ReturnObject.StatusCode = $StatusCode
	$ReturnObject.DetailedError = $DetailedError
	$ReturnObject.Data = $Data
    
    

	return $ReturnObject
}

###############################################################################
## Export Cmdlets
###############################################################################

Export-ModuleMember *-*
