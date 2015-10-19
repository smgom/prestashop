<script src="https://beautiful.start.payfort.com/checkout.js"></script>
<style>
 .payfortstart_form a:hover {
    background-color: #f6f6f6 !important;
    text-decoration: underline !important;
}
    </style>
	<div class="row"><div class="col-xs-12">
            <form name="payfortstart_form" id="payfortstart_form" action="{$module_dir}validation.php" method="post">
               <input name="x_invoice_num" type="hidden" value="{$x_invoice_num}">
                 <input name="amount" type="hidden" value="{$amount}">
                <p class="payment_module">
                    <a id="click_payfortstart" title="{l s='Pay with PayfortStart' mod='payfortstart'}" style="display: block; cursor:pointer;">
                       <img src="{$module_dir}img/cc.png"/>
                        Pay With Debit/Credit Card		
                    </a>
                </p>
           </form>
        </div>
    </div>
                   
{if $isFailed == 1}		
<p id="payfort_start_error" style="color: red;">			
    {if !empty($smarty.get.message)}
        {l s=' ' mod='payfortstart'}
        {$smarty.get.message|htmlentities}
    {else}	
        {l s='Error, please verify the card information' mod='payfortstart'}
    {/if}
</p>
{/if}
    <br class="clear" />			
</form>
</p><script type="text/javascript">
    function submitFormWithToken(param) {
        removePaymentToken();
{*        $('#payfortstart_form').append("<span class='start_response'><br>Your Card: xxxx-xxxx-xxxx-<b>" + param.token.card.last4 + "</b> <a href='javascript:void(0)' onclick=removePaymentToken();>(Clear)</a></span>");*}
        $('#payfortstart_form').append("<span class='start_response'><img src='modules/payfortstart/img/widget-loading.gif' /></span>");
        $('#payfortstart_form').parent().find(".start_response").append("<input type = 'hidden' name='payment_token' value = " + param.token.id + "><input type = 'hidden' name='payment_email' value = " + param.email + ">");
        $('#payfortstart_form').trigger('submit'); 
    }
    function removePaymentToken() {
        $('#payfortstart_form').find(".start_response").remove();
        $('#payfort_start_error').remove();
    }
    $(document).ready(function () {
        $("#click_payfortstart").on("click", function () {
            StartCheckout.config({
                key: "{$configuration_open_key}",
                complete: function (params) {
                    submitFormWithToken(params);
                }
            });
            StartCheckout.open({
                amount: "{$amount_in_cents}",
                currency: "{$currency}",
                email: "{$email}"
            });
        });
    });
</script>
