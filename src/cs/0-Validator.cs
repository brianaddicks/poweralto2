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