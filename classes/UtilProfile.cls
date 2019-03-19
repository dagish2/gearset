public class UtilProfile {

	private static Id sysAdminId;
	private static map <string, Id> mapProfileNameToId = new map <string, Id>();
	private static map <Id, string> mapProfileIdToName = new map <Id, string>();

	
	public static Id getSysAdminProfileId()
	{
		if(sysAdminId == null)
		{
			sysAdminId = getNameToIdMap().get('System Administrator');
		}

		return sysAdminId;
	}

	public static map <string, Id> getNameToIdMap ()
	{
		if(mapProfileNameToId.isEmpty())
		{
			list <Profile> lstProfiles = [Select Id, Name 
										  From Profile];

			for(Profile curProfile :lstProfiles)
			{
				mapProfileNameToId.put(curProfile.Name, curProfile.Id);
				mapProfileIdToName.put(curProfile.Id, curProfile.Name);
			}
		}

		return mapProfileNameToId;
	}

	public static map <Id, string> getIdToNameMap ()
	{
		if(mapProfileIdToName.isEmpty())
		{
			list <Profile> lstProfiles = [Select Id, Name 
										  From Profile];

			for(Profile curProfile :lstProfiles)
			{
				mapProfileNameToId.put(curProfile.Name, curProfile.Id);
				mapProfileIdToName.put(curProfile.Id, curProfile.Name);
			}
		}

		return mapProfileIdToName;
	}
}