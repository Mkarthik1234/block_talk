import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MetamaskErrorCustomDialogBox extends StatelessWidget {
  const MetamaskErrorCustomDialogBox({super.key});

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      child: CardDialog(),
      );
  }
}

class CardDialog extends StatelessWidget {
  const CardDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      decoration: BoxDecoration(
          color: Colors.grey[800], borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('images/metamask_gif2.webp', width: 150),
          const SizedBox(
            height: 30,
          ),
          const Text(
            "Alert",
            style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          RichText(
            text: const TextSpan(children: [
              TextSpan(
                  text: "Metamask",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              TextSpan(text:" is not installed please install the extension ",style: TextStyle(color: Colors.white)),
              TextSpan(text: ":)",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20))
            ]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            child: const Text("For more details click here",textAlign: TextAlign.center,style: TextStyle(color: Colors.blue,fontSize: 13),),
            onTap: ()=>launch('https://support.metamask.io/hc/en-us/articles/360015489531-Getting-started-with-MetaMask'),
          )
        ],
      ),
    );
  }
}
