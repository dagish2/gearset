<aura:application extends="force:slds">
    <aura:attribute name="settings" type="Object" />
    <aura:attribute name="searchResult" type="List" default="[]" />
    <aura:attribute name="msg" type="String" />
	<c:EnziUtils aura:id="utils"></c:EnziUtils>
    <button onclick="{!c.create}">create</button>
    {!v.msg}
</aura:application>