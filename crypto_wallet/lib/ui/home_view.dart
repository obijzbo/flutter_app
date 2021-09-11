import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_wallet/net/api_methods.dart';
import 'package:crypto_wallet/net/flutterfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crypto_wallet/ui/add_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  double? bitcoin = 0.0;
  double? ethereum = 0.0;
  double? cardano = 0.0;
  double? tether = 0.0;
  double? polkadot = 0.0;
  double? helium = 0.0;

  @override
  void initState(){
    updateValues();
  }

  updateValues() async{
    bitcoin = await getPrice("bitcoin");
    ethereum = await getPrice("ethereum");
    cardano = await getPrice("cardano");
    tether = await getPrice("tether");
    polkadot = await getPrice("polkadot");
    helium = await getPrice("helium");

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    getValue(String id, double amount){
      if (id == "bitcoin") {
        return (bitcoin! * amount).toStringAsFixed(2);
      } else if (id == "ethereum") {
        return (ethereum! * amount).toStringAsFixed(2);
      } else if (id == "cardano") {
        return (cardano! * amount).toStringAsFixed(2);
      } else if (id == "tether") {
        return (tether! * amount).toStringAsFixed(2);
      } else if (id == "polkadot") {
        return (polkadot! * amount).toStringAsFixed(2);
      } else {
        return (helium! * amount).toStringAsFixed(2);
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .collection('Coins')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                      child: Card(
                          color: Colors.amber,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0,),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Coin: ${document.id}", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),),
                                SizedBox(width: 3.0,),
                                Text(
                                    "Price: ${getValue(document.id, document.data()['Amount'])}", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),),
                                SizedBox(width: 3.0,),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                  ),
                                  onPressed: () async{
                                    await removeCoin(document.id);
                                  },
                                ),
                              ],
                            ),
                          )),
                    );
                  }).toList(),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddView(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
