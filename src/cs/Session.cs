namespace PowerAlto {
  public class Session {
	public double Id;
    public string StartTime;
	public int Timeout;
	public int TimeToLive;
	public double TotalBytesC2S;
	public double TotalBytesS2C;
	public double Layer7PacketsC2S;
	public double Layer7PacketsS2C;
	public string Vsys;
    public string Application;
	public string Rule;
	
	public string SourceZone;
	public string DestinationZone;
	
	public bool SessionLoggedAtEnd;
	public bool SessionInAger;
	public bool SessionUpdatedToPeer;
	
	public string Layer7Processing;
	public bool UrlFiltering;
	public string UrlCategory;
	
	public bool SessionViaSynCookies;
	public bool SessionTerminatedOnHost;
	public bool SessionTraversesTunnel;
	public bool CaptivePortal;
	
	public string IngressInterface;
	public string EgressInterface;
	
	public string QosRule;
	public string TrackerStage;
	
	public string EndReason;
	
	public Flow FlowC2S;
	public Flow FlowS2C;
  }
}