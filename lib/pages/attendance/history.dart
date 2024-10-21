import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/attendance/data.dart';
import 'package:new_unikl_link/types/info/student_semester.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:new_unikl_link/components/attendance_entry.dart';
import 'package:new_unikl_link/types/attendance/entry.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final Future<SharedPreferences> storeFuture;

  const AttendanceHistoryPage({
    super.key,
    required this.sharedPrefs,
  });

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistory();
}

class _AttendanceHistory extends State<AttendanceHistoryPage>
    with SingleTickerProviderStateMixin {
  List<String> _tabs = [];
  List<Widget> _tabViews = [];
  late final TabController _tabController;
  final ECitieURLs _eCitieURLs = ECitieURLs();
  final ECitieQuery _eCitieQuery = ECitieQuery();
  bool _dataLoaded = false;

  @override
  void initState() {
    widget.storeFuture.then((store) {
      http
          .get(Uri.parse(_eCitieURLs.serverQuery(
              store.getString("eCitieToken")!,
              _eCitieQuery.semesterData
                  .replaceAll("|STUDENTID|", store.getString("personID")!))))
          .then((resp) {
        StudentSemesterData semesterData =
            StudentSemesterData(jsonDecode(resp.body));
        http
            .get(Uri.parse(_eCitieURLs.serverQuery(
                store.getString("eCitieToken")!,
                _eCitieQuery.subjects
                    .replaceFirst("|SEMCODE|", semesterData.latest.code)
                    .replaceFirst(
                        "|STUDENTID|", store.getString("personID")!))))
            .then((resp) {
          AttendanceData attendanceData = AttendanceData(jsonDecode(resp.body));
          http
              .get(Uri.parse(_eCitieURLs.serverQuery(
                  store.getString("eCitieToken")!,
                  _eCitieQuery.attendanceHistory
                      .replaceFirst("|SEMCODE|", semesterData.latest.code)
                      .replaceFirst(
                          "|STUDENTID|", store.getString("personID")!))))
              .then((resp) {
            attendanceData.addEntries(jsonDecode(resp.body));
            int pos = 0;
            for (String subject in attendanceData.subjects) {
              _tabs.add(subject);
              _tabViews.add(SubjectTab(
                subject: attendanceData.entryData[pos],
                subjectName: subject,
              ));
              pos++;
            }
            setState(() {
              _tabController = TabController(length: _tabs.length, vsync: this);
              _dataLoaded = true;
            });
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverSafeArea(
                top: false,
                sliver: MultiSliver(children: [
                  SliverAppBar.large(
                    floating: true,
                    title: const Text(
                      "Attendance History",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      if (!_dataLoaded) ...[
                        const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Center(
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        )
                      ],
                    ],
                  ),
                  if (_dataLoaded) ...[
                    LoadedDataTabs(tabController: _tabController, tabs: _tabs)
                  ]
                ])),
          )
        ],
        body: _dataLoaded
            ? LoadedBody(tabController: _tabController, tabViews: _tabViews)
            : const UnloadedBody(),
      ),
    );
  }
}

class LoadedDataTabs extends StatelessWidget {
  const LoadedDataTabs({
    Key? key,
    required TabController tabController,
    required List tabs,
  })  : _tabController = tabController,
        _tabs = tabs,
        super(key: key);

  final TabController _tabController;
  final List _tabs;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Theme.of(context).colorScheme.primary,
        tabs: [
          ..._tabs.map((e) => Tab(
                child: Text(
                  e,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
              ))
        ],
      )),
      pinned: true,
    );
  }
}

class UnloadedBody extends StatelessWidget {
  const UnloadedBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(builder: (context) {
        return CustomScrollView(
          slivers: [
            SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              sliver: SliverToBoxAdapter(
                  child: Center(
                child: Text("Loading Attendance Data..."),
              )),
            )
          ],
        );
      }),
    );
  }
}

class LoadedBody extends StatelessWidget {
  final TabController tabController;
  final List<Widget> tabViews;

  const LoadedBody({
    super.key,
    required this.tabController,
    required this.tabViews,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(controller: _tabController, children: [
      ..._tabViews.map((tabView) {
        return SafeArea(
          top: false,
          bottom: false,
          child: Builder(builder: (context) {
            return tabView;
          }),
        );
      })
    ]);
  }
}

class SubjectTab extends StatelessWidget {
  const SubjectTab({
    super.key,
    required this.subject,
    required this.subjectName,
  });

  final List<AttendanceEntryData> subject;
  final String subjectName;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index != 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: AttendanceEntry(
                    date: subject[index].date,
                    classType: subject[index].classType,
                    attendStatus: subject[index].attendStatus,
                  ),
                );
              } else {
                return AttendanceEntry(
                  date: subject[index].date,
                  classType: subject[index].classType,
                  attendStatus: subject[index].attendStatus,
                );
              }
            }, childCount: subject.length),
          ),
        )
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
          color: overlapsContent
              ? Color.alphaBlend(
                  Theme.of(context).colorScheme.surfaceTint.withAlpha(20),
                  Theme.of(context).colorScheme.surface)
              : Theme.of(context).colorScheme.surface),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
