import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jiyu/backup/upload.dart';
import 'package:jiyu/ui/AppDrawer.dart';
import 'package:jiyu/ui/AddPage.dart';
import 'package:jiyu/sqlite-database/watching.dart';
import 'package:jiyu/sqlite-database/dropped.dart';

class DroppedPage extends StatefulWidget {
  @override
  _DroppedPageState createState() => _DroppedPageState();
}

class _DroppedPageState extends State<DroppedPage> {
  @override
  void initState() {
    super.initState();
    refreshList();
  }

  final backgroundColor = Color(0xFF2d3447);
  var anime = getDropped();

  Widget gridView(List<Dropped> data) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      itemCount: (data != null) ? data.length : 0,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
            padding: EdgeInsets.all(5.0),
            child: Card(
              child: Hero(
                tag: data[index].name,
                child: Material(
                    child: InkWell(
                  child: GridTile(
                    footer: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.zero,
                        topRight: Radius.zero,
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                      child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            colors: [Colors.blue[800], Colors.blue[500]],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                          child: ListTile(
                            title: Text(
                              data[index].name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: (data[index].total_episodes == 0)
                                ? Text(data[index].watched_episodes.toString() +
                                    "/?")
                                : Text(data[index].watched_episodes.toString() +
                                    "/" +
                                    data[index].total_episodes.toString()),
                            isThreeLine: false,
                            onLongPress: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: this.backgroundColor,
                                      actions: <Widget>[
                                        FlatButton(
                                            onPressed: () async {
                                              await insertWatching(Watching(
                                                  id: data[index].id,
                                                  url: data[index].url,
                                                  name: data[index].name,
                                                  img: data[index].img,
                                                  total_episodes: data[index]
                                                      .total_episodes,
                                                  watched_episodes: data[index]
                                                      .watched_episodes));
                                              await deleteDropped(
                                                  data[index].id);
                                              Navigator.of(context).pop();
                                              refreshList();
                                              upload();
                                            },
                                            child: Text("Add to Watching")),
                                        FlatButton(
                                            onPressed: () async {
                                              await deleteDropped(
                                                  data[index].id);
                                              Navigator.of(context).pop();
                                              refreshList();
                                              upload();
                                            },
                                            child: Text("Delete"))
                                      ],
                                    );
                                  });
                            },
                          )),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        data[index].img,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )),
              ),
            ));
      },
      staggeredTileBuilder: (int index) => StaggeredTile.count(1, 2),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
    );
  }

  var _refreshKey = GlobalKey<RefreshIndicatorState>();
  Future<Null> refreshList() async {
    _refreshKey.currentState?.show();
    await Future.delayed(Duration(milliseconds: 1500));
    setState(() {
      anime = getDropped();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: this.backgroundColor,
      drawer: AppDrawer(true, true, false, true),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: this.backgroundColor,
        title: Text(
          "Dropped",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: refreshList,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: FutureBuilder(
              future: anime,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return gridView(snapshot.data);
                }
                if (snapshot.data == null || snapshot.data.length) {
                  return Text("You have not dropped anything",
                      style: TextStyle(fontSize: 20.0, color: Colors.grey));
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: this.backgroundColor,
                  title: Text("Add"),
                  content: AddPage(),
                );
              });
        },
        elevation: 8.0,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
