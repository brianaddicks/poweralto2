namespace PowerAlto {
  public class Session {
	public double Id;
    public string StartTime;
	
	public int    Timeout;
	public int    TimeToLive;
	
	public string Vsys;
	public string SecurityRule;
	
	public string Application;
	public int    Protocol;
	public string State;
	
	// Nat properties
	public bool   Nat;
	public string NatRule;
	public bool   SourceNat;
	public bool   DestinationNat;
	
	public string TranslatedSource;
	public string TranslatedSourcePort;
	public string TranslatedDestination;
	public string TranslatedDestinationPort;
	
	// Source
	public string Source;
	public string SourceZone;
	public int    SourcePort;
	public string SourceUser;
	
	public string IngressInterface;
	
	// Destination
	public string Destination;
	public string DestinationZone;
	public int    DestinationPort;
	public string DestinationUser;
	
	public string EgressInterface;
  }
}