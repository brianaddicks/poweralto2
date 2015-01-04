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
//    public List<AddressObject> SourceAddress { get; set; }
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