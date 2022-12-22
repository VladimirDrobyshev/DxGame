void ETHCallback_dx_eagle(ETHEntity @thisEntity) {
	if (thisEntity.CheckCustomData("isInitialized") == DT_NODATA) {
		thisEntity.SetInt("isInitialized", 1);
		thisEntity.SetFloat("flyDistance", 60.0f);
		thisEntity.SetFloat("verSpeed", 0.5f);
		thisEntity.SetFloat("pathDistance", 0.0f);
		thisEntity.SetUInt("state", 0);		// 0 - down, 1 - up'
		thisEntity.SetUInt("startTime", GetTime());
		thisEntity.SetVector2("position", thisEntity.GetPositionXY());
	}

	float delta = float(GetTime() - thisEntity.GetInt("startTime"));
	float dist = thisEntity.GetInt("flyDistance");
	
	thisEntity.SetPositionXY(thisEntity.GetVector2("position") + vector2(cos(delta / 400.0f) * 10, sin(delta / 600.0f) * 30));
}