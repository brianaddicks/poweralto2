using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Xml;

namespace PowerAlto {
  public class Tag : PowerAltoBaseObject {
  
    public string Name { get; set; }
    public string Comments { get; set; }
    
    // ----------------------------- Color and Validation ------------------------- //
    private Dictionary<string, string> validColors = new Dictionary<string, string>() {
      {"none", "none"},
      {"red","color1"},
      {"green","color2"},
      {"blue","color3"},
      {"yellow","color4"},
      {"copper","color5"},
      {"orange","color6"},
      {"purple","color7"},
      {"gray","color8"},
      {"light green","color9"},
      {"cyan","color10"},
      {"light gray","color11"},
      {"blue gray","color12"},
      {"lime","color13"},
      {"black","color14"},
      {"gold","color15"},
      {"brown","color16"}
    };
    
    private string color;
    public string Color {
      get {
        return this.color;
      }
      set {
        if (validColors.ContainsKey(value)) {
          if (value == "none") {
            this.color = null;
          } else {
            this.color = value;
          }
        } else if (String.IsNullOrEmpty(value)) {
          this.color = null;
        } else {
          string items = null;
          foreach (string item in validColors.Keys) {
            if (String.IsNullOrEmpty(items)) {
              items = item;
            } else {
              items += ", ";
              items += item;
            }
          }
          throw new ArgumentOutOfRangeException("Invalid value. Valid values are: " + items);
        }
      }
    }
    
    // ------------------------------------ XML ---------------------------------- //
    public override XElement Xml () {
                    
			// Create root
			XDocument XmlObject = new XDocument();
			
			// create entry node and define name attribute
			XElement xmlEntry = new XElement("entry");
			xmlEntry.SetAttributeValue("name",this.Name);
			XmlObject.Add(xmlEntry);
      
      if (!(String.IsNullOrEmpty(this.color))) {
        string colorCode;
        if (validColors.TryGetValue(this.color, out colorCode)) {
          XmlObject.Element("entry").Add( createXmlWithoutMembers( "color", colorCode));	// Color
        }
      }
      
      
			XmlObject.Element("entry").Add( createXmlWithoutMembers( "comments", this.Comments));	// Comments
			

			return XmlObject.Element("entry");
	  }

    public string XPath {
      get {
        string baseXPath = "/config/devices/entry/vsys/entry/tag";
        return baseXPath;
      }
    }
  }
}