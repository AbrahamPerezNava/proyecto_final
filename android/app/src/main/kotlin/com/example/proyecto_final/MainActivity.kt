package com.example.proyecto_final

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import com.mercadopago.android.px.core.MercadoPagoCheckout
import com.mercadopago.android.px.model.Payment
import io.flutter.embedding.android.FlutterActivity

import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterMain

class MainActivity: FlutterActivity() {

    private val REQUEST_CODE = 1;
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initFlutterChannels()
    }

    private fun initFlutterChannels() {
        val channelMercadoPago = MethodChannel(getFlutterEngine()!!.getDartExecutor().getBinaryMessenger(), "waviacademy.com/mercadoPago")

        channelMercadoPago.setMethodCallHandler { methodCall, result ->
            val args = methodCall.arguments as HashMap<String, Any>;
            val publicKey = args["publicKey"] as String
            val preferenceId = args["preferenceId"] as String;

            when(methodCall.method) {
                "mercadoPago" -> mercadoPago(publicKey, preferenceId, result)
                else -> return@setMethodCallHandler
            }
        }
    }

    private fun mercadoPago(publicKey: String, preferenceId: String, channelResult: MethodChannel.Result) {
        MercadoPagoCheckout.Builder(publicKey, preferenceId).build().startPayment(this@MainActivity, REQUEST_CODE)
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val channelMercadoPagoRespuesta = MethodChannel(getFlutterEngine()!!.getDartExecutor().getBinaryMessenger(), "waviacademy.com/mercadoPagoRespuesta")
        if(resultCode == MercadoPagoCheckout.PAYMENT_RESULT_CODE) {
            val payment = data!!.getSerializableExtra(MercadoPagoCheckout.EXTRA_PAYMENT_RESULT) as Payment
            val paymentStatus = payment.paymentStatus
            val paymentStatusDetails = payment.paymentStatusDetail
            val paymentID = payment.id

            val arrayList = ArrayList<String>()
            arrayList.add(paymentID.toString())
            arrayList.add(paymentStatus)
            arrayList.add(paymentStatusDetails)

            channelMercadoPagoRespuesta.invokeMethod("mercadoPagoOK", arrayList)
        } else if (resultCode == Activity.RESULT_CANCELED) {
            val arrayList = ArrayList<String>()
            arrayList.add("pagoError")
            channelMercadoPagoRespuesta.invokeMethod("mercadoPagoError", arrayList)
        } else {
            val arrayList = ArrayList<String>()
            arrayList.add("pagoCancelado")
            channelMercadoPagoRespuesta.invokeMethod("mercadoPagoError", arrayList)
        }
    }



}