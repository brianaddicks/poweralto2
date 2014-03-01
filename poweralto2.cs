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

namespace PowerAlto {
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
				if (!string.IsNullOrEmpty(this.Protocol) && !string.IsNullOrEmpty(this.Device) && this.Port > 0) {
					return this.Protocol + "://" + this.Device + ":" + this.Port + "/api/";
				} else {
					return null;
				}
			}
		}
		
		public string AuthString {
			get {
				if (!string.IsNullOrEmpty(this.ApiKey)) {
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
				this.clock = DateTime.Parse(value);
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
		
		public void FlushHistory () {
			this.urlhistory.Clear();
		}
		
		
		public string UrlBuilder (string QueryString) {
			
			string[] Pieces = new string[5];
			Pieces[0] = this.ApiUrl;
			Pieces[1] = "?";
			Pieces[2] = this.AuthString;
			Pieces[3] = "&";
			Pieces[4] = QueryString;
			
			//if (QueryType == "op") {
			//	Pieces[5] += ("&cmd=" + Query);
			//}
			
			string CompletedString = string.Join ("",Pieces);
			
			this.urlhistory.Push(CompletedString);
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
		
	}
	
	public class SecurityRule {
	
		public string Name { get; set; }
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
		
		//private bool IsGroup = false;
		private bool ProfileExists = false;
		
		private string profilegroup;
		public string ProfileGroup {
			get {
				return this.profilegroup;
			}
			set {
				if (this.ProfileExists) {
					throw new System.ArgumentException("Profile Group cannot be set with individual profiles");
				} else {
					this.profilegroup = value;
				}
			}
		}
		
		
		private string antivirusprofile;
		public string AntivirusProfile {
			get {
				return this.antivirusprofile;
			}
			set {
				this.antivirusprofile = value;
				this.ProfileExists = true;
			}
		}
		
		//public string VulnerabilityProfile { get; set; }
		private string vulnerabilityprofile;
		public string VulnerabilityProfile {
			get {
				return this.vulnerabilityprofile;
			}
			set {
				this.vulnerabilityprofile = value;
				this.ProfileExists = true;
			}
		}
		
		public string AntiSpywareProfile { get; set; }
		public string UrlFilteringProfile { get; set; }
		public string FileBlockingProfile { get; set; }
		public string DataFilteringProfile { get; set; }
		
		public bool LogAtSessionStart { get; set; }
		public bool LogAtSessionEnd { get; set; }
		public string LogForwarding { get; set; }
		
		public string Schedule { get; set; }
		public string QosType { get; set; }
		public string QosMarking { get; set; }
		
		public bool DisableSRI { get; set; }
		
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


			// ---------------------------------- Description and Tags ---------------------------------- //
			XmlObject.Element("entry").Add( createXmlWithoutMembers( "description", this.Description ));	// Description
			XmlObject.Element("entry").Add( createXmlWithMembers( "tag", this.Tags ));				            // Tags
			// ------------------------------------------------------------------------------------------ //


			// ---------------------------------------- Zones ----------------------------------------- //
			XmlObject.Element("entry").Add( createXmlWithMembers( "from", this.SourceZone, true ));			// Source Zones
			XmlObject.Element("entry").Add( createXmlWithMembers( "to", this.DestinationZone, true ));	// Destination Zones
			// ---------------------------------------------------------------------------------------- //


			// -------------------------------------------- Addresses --------------------------------------------- //
			XmlObject.Element("entry").Add( createXmlWithMembers( "source", this.SourceAddress, true ));						// Source Addresses
			XmlObject.Element("entry").Add( createXmlWithMembers( "destination", this.DestinationAddress, true ));	// Destination Address
			// ---------------------------------------------------------------------------------------------------- //


			// ------------------------------------ Users and Hip Profiles ------------------------------------ //
			XmlObject.Element("entry").Add( createXmlWithMembers( "source-user", this.SourceUser, true ));      // Source User
			XmlObject.Element("entry").Add( createXmlWithMembers( "hip-profiles", this.HipProfile, true ));     // Hip Profiles
			// ------------------------------------------------------------------------------------------------ //


			// -------------------------- Applications, Services, and URL Category --------------------------- //
			XmlObject.Element("entry").Add( createXmlWithMembers( "application", this.Application, true ));    // Applications
			XmlObject.Element("entry").Add( createXmlWithMembers( "service", this.Service, true ));            // Services
			XmlObject.Element("entry").Add( createXmlWithMembers( "category", this.UrlCategory, true ));       // Url Category
			// ----------------------------------------------------------------------------------------------- //


			// ------------------------------------- Address Negation ------------------------------------- //
			XmlObject.Element("entry").Add( createXmlBool( "negate-source", this.SourceNegate ));			      // Source Negate
			XmlObject.Element("entry").Add( createXmlBool( "negate-destination", this.DestinationNegate ));	// Destination Negate
			// -------------------------------------------------------------------------------------------- //

			
			// ----------------------------------- Action ----------------------------------- //
			XElement xmlAction = new XElement("action");
			if (this.Allow) { xmlAction.Value = "allow"; } 																		// Allow
			           else { xmlAction.Value = "deny";  }																		// Deny
			XmlObject.Element("entry").Add(xmlAction);
			// ------------------------------------------------------------------------------ //


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


			// -------------------------------- Log Settings -------------------------------- //
			XmlObject.Element("entry").Add( createXmlBool( "log-start", this.LogAtSessionStart));				  				// Log At Start
			XmlObject.Element("entry").Add( createXmlBool( "log-end", this.LogAtSessionEnd));					  					// Log At End
			XmlObject.Element("entry").Add( createXmlWithoutMembers( "log-setting", this.LogForwarding));		  		// Log Forwarding
			// ------------------------------------------------------------------------------ //


			// ----------------------------- Schedule and DSRI ------------------------------ //
			XmlObject.Element("entry").Add( createXmlWithoutMembers( "schedule", this.Schedule));				  				// Schedule
			// ------------------------------------------------------------------------------ //

			// Set Disable Server Response Inspection
			XElement xmlDisableSRI = new XElement("option");
			if (this.DisableSRI) {
				xmlDisableSRI.Element("option").Add( createXmlWithoutMembers( "disable-server-response-inspection", "yes" ));
			} else {
				xmlDisableSRI.Element("option").Add( createXmlWithoutMembers( "disable-server-response-inspection", "no" ));
			}
			XmlObject.Element("entry").Add(xmlDisableSRI);


			
			// Set Qos Marking
			if (!(String.IsNullOrEmpty(this.QosMarking)) && !(String.IsNullOrEmpty(this.QosType))) {
				XElement QosXml = new XElement("qos",
					new XElement("marking")
				);
				
				if (this.QosType == "dscp") {
					XElement QosMarkingXml = new XElement("ip-dscp",this.QosMarking);
					QosXml.Element("marking").Add(QosMarkingXml);
				} else {
					XElement QosMarkingXml = new XElement("ip-precedence",this.QosMarking);
					QosXml.Element("marking").Add(QosMarkingXml);
				}
				
				XmlObject.Element("entry").Add(QosXml);
			}
			
			
			return XmlObject.Element("entry");
	    }

		public string PrintPrettyXml() {
			return Xml().ToString();
		}
		
		public string PrintPlainXml() {
			return Xml().ToString(SaveOptions.DisableFormatting);
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










