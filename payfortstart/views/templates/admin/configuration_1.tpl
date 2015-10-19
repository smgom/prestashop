<div class="payfortstart-wrapper">
<form action="{$smarty.server.REQUEST_URI|escape:'htmlall':'UTF-8'}" method="post">
	<fieldset>
		<legend>{l s='Configure your Payfort Start Payment Gateway' mod='payfortstart'}</legend>
				{assign var='configuration_live_open_key' value="PAYFORT_START_LIVE_OPEN_KEY"}
				{assign var='configuration_live_secret_key' value="PAYFORT_START_LIVE_SECRET_KEY"}
                                {assign var='configuration_test_open_key' value="PAYFORT_START_TEST_OPEN_KEY"}
				{assign var='configuration_test_secret_key_' value="PAYFORT_START_TEST_SECRET_KEY"}
				<table>
					<tr>
						<td>
							<p>{l s='Credentials for' mod='payfortstart'}</p>
							<label for="payfortstart_login_id">{l s='Live Open Key' mod='payfortstart'}:</label>
							<div class="margin-form" style="margin-bottom: 0px;"><input type="text" size="50" id="PAYFORT_START_LIVE_OPEN_KEY" name="PAYFORT_START_LIVE_OPEN_KEY" value="{$PAYFORT_START_LIVE_OPEN_KEY}" /></div>
							<label for="payfortstart_key">{l s='Live Secret Key' mod='payfortstart'}:</label>
							<div class="margin-form" style="margin-bottom: 0px;"><input type="text" size="50" id="PAYFORT_START_LIVE_SECRET_KEY" name="PAYFORT_START_LIVE_SECRET_KEY" value="{${$configuration_live_secret_key}}" /></div>
                                                        <label for="payfortstart_login_id">{l s='Test Open Key' mod='payfortstart'}:</label>
							<div class="margin-form" style="margin-bottom: 0px;"><input type="text" size="50" id="PAYFORT_START_TEST_OPEN_KEY" name="PAYFORT_START_TEST_OPEN_KEY" value="{${$configuration_test_open_key}}" /></div>
							<label for="payfortstart_key">{l s='Test Secret Key' mod='payfortstart'}:</label>
							<div class="margin-form" style="margin-bottom: 0px;"><input type="text" size="50" id="PAYFORT_START_TEST_SECRET_KEY" name="PAYFORT_START_TEST_SECRET_KEY" value="{${$configuration_test_secret_key}}" /></div>
                                                </td>
					</tr>
				</table><br />
				<hr size="1" style="background: #BBB; margin: 0; height: 1px;" noshade /><br />

		<label for="payfortstart_mode"><a class="payfortstart-sign-up" target="_blank" href="https://developer.authorize.net/guides/AIM/wwhelp/wwhimpl/js/html/wwhelp.htm"><img src="{$module_dir}img/help.png" alt="" /></a> {l s='Environment:' mod='payfortstart'}</label>
		<div class="margin-form" id="payfortstart_mode">
			<input type="radio" name="payfortstart_mode" value="0" style="vertical-align: middle;" {if !$PAYFORT_START_SANDBOX && !$PAYFORT_START_TEST_MODE}checked="checked"{/if} />
			<span>{l s='Live mode' mod='payfortstart'}</span><br/>
			<input type="radio" name="payfortstart_mode" value="1" style="vertical-align: middle;" {if !$PAYFORT_START_SANDBOX && $PAYFORT_START_TEST_MODE}checked="checked"{/if} />
			<span>{l s='Test mode (in production server)' mod='payfortstart'}</span><br/>
			<input type="radio" name="payfortstart_mode" value="2" style="vertical-align: middle;" {if $PAYFORT_START_SANDBOX}checked="checked"{/if} />
			<span>{l s='Test mode' mod='payfortstart'}</span><br/>
		</div>
		<label for="payfortstart_cards">{l s='Cards* :' mod='payfortstart'}</label>
		<div class="margin-form" id="payfortstart_cards">
			<input type="checkbox" name="payfortstart_card_visa" {if $PAYFORT_START_CARD_VISA}checked="checked"{/if} />
				<img src="{$module_dir}/cards/visa.gif" alt="visa" />
			<input type="checkbox" name="payfortstart_card_mastercard" {if $PAYFORT_START_CARD_MASTERCARD}checked="checked"{/if} />
				<img src="{$module_dir}/cards/mastercard.gif" alt="visa" />
			<input type="checkbox" name="payfortstart_card_discover" {if $PAYFORT_START_CARD_DISCOVER}checked="checked"{/if} />
				<img src="{$module_dir}/cards/discover.gif" alt="visa" />
			<input type="checkbox" name="payfortstart_card_ax" {if $PAYFORT_START_CARD_AX}checked="checked"{/if} />
				<img src="{$module_dir}/cards/ax.gif" alt="visa" />
		</div>

		<label for="payfortstart_hold_review_os">{l s='Order status:  "Hold for Review" ' mod='payfortstart'}</label>
		<div class="margin-form">
			<select id="payfortstart_hold_review_os" name="payfortstart_hold_review_os">';
				// Hold for Review order state selection
				{foreach from=$order_states item='os'}
					<option value="{if $os.id_order_state|intval}" {((int)$os.id_order_state == $PAYFORT_START_HOLD_REVIEW_OS)} selected{/if}>
						{$os.name|stripslashes}
					</option>
				{/foreach}
			</select>
		</div>
		<br />
		<center>
			<input type="submit" name="submitModule" value="{l s='Update settings' mod='payfortstart'}" class="button" />
		</center>
		<sub>{l s='* Subject to region' mod='payfortstart'}</sub>
	</fieldset>
</form>
</div>
