using System.Text.RegularExpressions;

namespace PowerAlto {

  public class PowerAltoValidators {
    protected string nameAlphaNumDashDotUnder (string Name, int Length) {
      string namePattern =  @"^[a-zA-Z0-9\-_\.]{1," + Length + "}$";
      Regex nameRx = new Regex(namePattern);
      Match nameMatch = nameRx.Match(Name);
      if (nameMatch.Success) {
        return Name;
      } else {
        string errorMessage = null;
        if (Name.Length > Length) {
          errorMessage = "Value must be less that 15 characters or less.";
        } else {
          errorMessage = "Value must contain only alphanumeric, hyphens, underscores, or periods.";
        }
        throw new System.ArgumentException(errorMessage);
      }
    }
  }
}