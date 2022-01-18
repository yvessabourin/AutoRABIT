<aura:application >

    <link href='/resource/bootstrap/dist/css/bootstrap.css' rel="stylesheet"/>

    <div class="navbar navbar-default navbar-static-top" role="banner">
        <div class="container">
            <div class="navbar-header">
                <!-- <a href="#" class="navbar-brand">Redemption Campaigns</a> -->
                <h1>Redemption Campaigns</h1>
            </div>
        </div>
    </div>

	<div class="container">
        <div class="row">
            <div class="col-sm-10">
                <c:RedemptionCampaignsList />
            </div>

        </div>
    </div>

</aura:application>