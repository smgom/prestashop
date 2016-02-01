<?php

/*
 * 2007-2013 PrestaShop
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License (AFL 3.0)
 * that is bundled with this package in the file LICENSE.txt.
 * It is also available through the world-wide-web at this URL:
 * http://opensource.org/licenses/afl-3.0.php
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@prestashop.com so we can send you a copy immediately.
 *
 * DISCLAIMER
 *
 * Do not edit or add to this file if you wish to upgrade PrestaShop to newer
 * versions in the future. If you wish to customize PrestaShop for your
 * needs please refer to http://www.prestashop.com for more information.
 *
 *  @author PrestaShop SA <contact@prestashop.com>
 *  @copyright  2007-2013 PrestaShop SA
 *  @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 *  International Registered Trademark & Property of PrestaShop SA
 */

include(dirname(__FILE__) . '/../../config/config.inc.php');

function pr($data) {
    echo "<pre>";
    print_r($data);
    echo "<pre>";
}
include(dirname(__FILE__) . '/../../init.php');

/* will include backward file */
include(dirname(__FILE__) . '/payfortstart.php');

$payfortstart = new PayfortStart();

/* Does the cart exist and is valid? */
$cart = Context::getContext()->cart;

if (!isset($_POST['x_invoice_num'])) {
    Logger::addLog('Missing x_invoice_num', 4);
    die('An unrecoverable error occured: Missing parameter');
}

if (!Validate::isLoadedObject($cart)) {
    Logger::addLog('Cart loading failed for cart ' . (int) $_POST['x_invoice_num'], 4);
    die('An unrecoverable error occured with the cart ' . (int) $_POST['x_invoice_num']);
}

if ($cart->id != $_POST['x_invoice_num']) {
    Logger::addLog('Conflict between cart id order and customer cart id');
    die('An unrecoverable conflict error occured with the cart ' . (int) $_POST['x_invoice_num']);
}

$customer = new Customer((int) $cart->id_customer);
$invoiceAddress = new Address((int) $cart->id_address_invoice);
$currency = new Currency((int) $cart->id_currency);

if (!Validate::isLoadedObject($customer) || !Validate::isLoadedObject($invoiceAddress) && !Validate::isLoadedObject($currency)) {
    Logger::addLog('Issue loading customer, address and/or currency data');
    die('An unrecoverable error occured while retrieving you data');
}
if (Tools::safeOutput(Configuration::get('PAYFORT_START_TEST_MODE'))) {
    $start_payments_secret_api = Tools::safeOutput(Configuration::get('PAYFORT_START_TEST_SECRET_KEY'));
} else {
    $start_payments_secret_api = Tools::safeOutput(Configuration::get('PAYFORT_START_LIVE_SECRET_KEY'));
}
if (Tools::safeOutput(Configuration::get('PAYFORT_START_CAPTURE'))) {
    $capture = 0;
} else {
    $capture = 1;
}
$order_description = "Charge for order";
$order_id = $_POST['x_invoice_num'];
$email = $_POST['payment_email'];
$amount = $_POST['amount'];
include (dirname(__FILE__) . '/vendor/payfort/start/Start.php');
$userAgent = 'Prestashop ' . _PS_VERSION_ . ' / Start Plugin ' . $payfortstart->version;
Start::setUserAgent($userAgent);
Start::setApiKey($start_payments_secret_api);
$delivery_address = new Address(intval($cart->id_address_delivery));
$shipping_address = array(
    "first_name" => $delivery_address->firstname,
    "last_name" => $delivery_address->lastname,
    "country" => $delivery_address->country,
    "city" => $delivery_address->city,
    "address_1" => $delivery_address->address1,
    "address_2" => $delivery_address->address2,
    "phone" => $delivery_address->phone,
    "postcode" => $delivery_address->postcode
);

$billing_address = array(
    "first_name" => $invoiceAddress->firstname,
    "last_name" => $invoiceAddress->lastname,
    "country" => $invoiceAddress->country,
    "city" => $invoiceAddress->city,
    "address_1" => $invoiceAddress->address1,
    "address_2" => $invoiceAddress->address2,
    "phone" => $invoiceAddress->phone,
    "postcode" => $invoiceAddress->postcode
);
if (file_exists(dirname(__FILE__) . '/data/currencies.json')) {
    $currency_json_data = json_decode(file_get_contents(dirname(__FILE__) . '/data/currencies.json'), 1);
    $currency_multiplier = $currency_json_data[$currency->iso_code];
} else {
    $currency_multiplier = 100;
}
$amount_in_cents = $amount * $currency_multiplier;
$customer = new Customer((int) $cart->id_customer);
$registered_at = ($customer->is_guest == 0) ? date(DATE_ISO8601, strtotime(date("Y-m-d H:i:s"))) : date(DATE_ISO8601, strtotime($customer->date_add));
$products = $cart->getProducts(true);
$order_items_array_full = array();
foreach ($products as $key => $items) {
    $order_items_array['title'] = $items['name'];
    $order_items_array['amount'] = round($items['price'], 2) * $currency_multiplier;
    $order_items_array['quantity'] = $items['quantity'];
    array_push($order_items_array_full, $order_items_array);
}
$shopping_cart_array = array(
    'user_name' => $customer->firstname,
    'registered_at' => $registered_at,
    'items' => $order_items_array_full,
    'billing_address' => $billing_address,
    'shipping_address' => $shipping_address
);
$shipping_cost =  $cart->getTotalShippingCost()*$currency_multiplier;
$charge_args = array(
    'description' => $order_description . ': ' . $order_id, // only 255 chars
    'card' => $_POST['payment_token'],
    'currency' => $currency->iso_code,
    'email' => $email,
    'ip' => $_SERVER["REMOTE_ADDR"],
    'amount' => $amount_in_cents,
    'capture' => $capture,
    'shopping_cart' => $shopping_cart_array,
    'shipping_amount' => $shipping_cost,
    'metadata' => array('reference_id' => $order_id)
);
$json = array();
try {
    pr($charge_args);
    $charge = Start_Charge::create($charge_args);
    $url = 'index.php?controller=order-confirmation&';
    if (_PS_VERSION_ < '1.5')
        $url = 'order-confirmation.php?';
    $payfortstart->validateOrder((int) $cart->id, Configuration::get('PAYFORT_START_HOLD_REVIEW_OS'), (float) $amount, "credit/debit card", "message", NULL, NULL, false, $customer->secure_key);
    $auth_order = new Order($payfortstart->currentOrder);
    Tools::redirect($url . 'id_module=' . (int) $payfortstart->id . '&id_cart=' . (int) $cart->id . '&key=' . $auth_order->secure_key);
} catch (Start_Error_Banking $e) {
    if ($e->getErrorCode() == "card_declined") {
        $error_message = "Card declined. Please use another card";
    } else {
        $error_message = $e->getMessage();
    }
    $checkout_type = Configuration::get('PS_ORDER_PROCESS_TYPE') ?
            'order-opc' : 'order';
    $url = _PS_VERSION_ >= '1.5' ?
            'index.php?controller=' . $checkout_type . '&' : $checkout_type . '.php?';
    $url .= 'step=3&cgv=1&payfortstarterror=1&message=' . $error_message;

    if (!isset($_SERVER['HTTP_REFERER']) || strstr($_SERVER['HTTP_REFERER'], 'order'))
        Tools::redirect($url);
    else if (strstr($_SERVER['HTTP_REFERER'], '?'))
        Tools::redirect($_SERVER['HTTP_REFERER'] . '&aimerror=1&message=' . $error_message, '');
    else
        Tools::redirect($_SERVER['HTTP_REFERER'] . '?aimerror=1&message=' . $error_message, '');

    exit;
}
