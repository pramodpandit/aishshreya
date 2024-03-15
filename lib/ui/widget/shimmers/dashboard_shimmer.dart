import 'package:flutter/material.dart';
import 'package:aishshreya/ui/widget/shimmers/shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        const DashboardUserCardShimmer(),
        // const DashboardUserCardShimmer(),
        GridView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: 2,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 16.5/10,
          ),
          itemBuilder: (context, i) {
            return Stack(
              children: [
                Shimmer.rectangle(
                  height: size.width,
                  width: size.width,
                  borderRadius: 15,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CustomPlaceholder.circle(radius: 18),
                      SizedBox(height: 15),
                      CustomPlaceholder.rectangle(height: 22, width: 80,),
                      SizedBox(height: 8),
                      CustomPlaceholder.rectangle(height: 15, width: 50,),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const GraphShimmer(),
      ],
    );
  }
}

class GraphShimmer extends StatelessWidget {
  const GraphShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Shimmer.rectangle(
                    height: 18,
                    width: 80,
                  ),
                  SizedBox(height: 5),
                  Shimmer.rectangle(
                    height: 10,
                    width: 150,
                  ),
                ],
              ),
              const Shimmer.rectangle(height: 28, width: 60),
            ],
          ),
          Divider(color: Colors.grey[200]!, thickness: 1,),
          const Shimmer.rectangle(
            height: 200,
            width: 400,
          ),
          const SizedBox(height: 10),
          GridView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 25/10,
            ),
            itemCount: 2,
            itemBuilder: (context, i) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Shimmer.rectangle(
                      height: 20,
                      width: 80,
                    ),
                    SizedBox(height: 10),
                    Shimmer.rectangle(
                      height: 10,
                      width: 150,
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}


class DashboardUserCardShimmer extends StatelessWidget {
  const DashboardUserCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Stack(
        children: [
          Shimmer.rectangle(
            height: 150,
            width: size.width,
            borderRadius: 15,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 15, vertical: 10),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CustomPlaceholder.rectangle(height: 50, width: 50),
                    SizedBox(height: 10),
                    CustomPlaceholder.rectangle(height: 32, width: 150),
                    SizedBox(height: 10),
                    CustomPlaceholder.rectangle(height: 18, width: 60),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      CustomPlaceholder.circle(radius: 14),
                      SizedBox(width: 5),
                      CustomPlaceholder.rectangle(height: 28, width: 60),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      CustomPlaceholder.rectangle(height: 66, width: 55, borderRadius: 15,),
                      SizedBox(width: 8),
                      CustomPlaceholder.rectangle(height: 66, width: 55, borderRadius: 15,),
                      SizedBox(width: 8),
                      CustomPlaceholder.rectangle(height: 66, width: 55, borderRadius: 15,),
                      SizedBox(width: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
