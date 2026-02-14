namespace FixFlow.Application.Exceptions;

public class EntityHasDependentsException : Exception
{
    public EntityHasDependentsException(string entityName, string dependentName)
        : base($"Ne možete obrisati {entityName} jer ima povezane {dependentName}.") { }
}
