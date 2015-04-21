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
	public class Job {
    public int Id { get; set; }
    public string TimeEnqueued { get; set; }
    public string User { get; set; }
    public string Type { get; set; }
    public string Status { get; set; }
    public bool Stoppable { get; set; }
    public string Result { get; set; }
    public string TimeCompleted { get; set; }
    public string Details { get; set; }
    public string Warnings { get; set; }
    public int Progress { get; set; }
	}
}