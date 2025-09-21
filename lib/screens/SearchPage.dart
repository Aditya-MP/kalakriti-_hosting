import 'package:flutter/material.dart';
class SearchPage extends StatefulWidget {
	const SearchPage({super.key});
	@override
		SearchPageState createState() => SearchPageState();
	}
class SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
	Widget _buildCategoryButton(String label) {
		return Container(
			decoration: BoxDecoration(
				color: Color(0xFFF4F2EF),
				borderRadius: BorderRadius.circular(16),
			),
			padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
			child: Text(
				label,
				style: TextStyle(
					color: Color(0xFF161411),
					fontWeight: FontWeight.w600,
					fontSize: 16,
				),
			),
		);
	}
		String textField1 = '';
		late AnimationController _catAnimController;
		late Animation<Offset> _catOffsetAnimation;

		@override
		void initState() {
			super.initState();
			_catAnimController = AnimationController(
				duration: const Duration(milliseconds: 600),
				vsync: this,
			);
			_catOffsetAnimation = Tween<Offset>(
				begin: const Offset(1.0, 0.0),
				end: Offset.zero,
			).animate(CurvedAnimation(
				parent: _catAnimController,
				curve: Curves.easeOut,
			));
			_catAnimController.forward();
		}

		@override
		void dispose() {
			_catAnimController.dispose();
			super.dispose();
		}
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: Container(
					constraints: const BoxConstraints.expand(),
					color: Color(0xFFFFFFFF),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								child: Container(
									color: Color(0xFFFFFFFF),
									width: double.infinity,
									height: double.infinity,
									child: SingleChildScrollView(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												IntrinsicHeight(
													child: Container(
														color: Color(0xFFFFFFFF),
														width: double.infinity,
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																IntrinsicHeight(
																	child: Container(
																		width: double.infinity,
																		child: Column(
																			crossAxisAlignment: CrossAxisAlignment.start,
																			children: [
																				IntrinsicHeight(
																					child: Container(
																						color: Color(0xFFFFFFFF),
																						padding: const EdgeInsets.only( top: 16, bottom: 16, left: 64, right: 16),
																						width: double.infinity,
																						child: Row(
																							children: [
																								Expanded(
																									child: Container(
																										width: double.infinity,
																										child: Text(
																											"Rasik",
																											style: TextStyle(
																												color: Color(0xFF161411),
																												fontSize: 18,
																												fontWeight: FontWeight.bold,
																											),
																											textAlign: TextAlign.center,
																										),
																									),
																								),
																							]
																						),
																					),
																				),
																				IntrinsicHeight(
																					child: Container(
																						padding: const EdgeInsets.only( top: 12, bottom: 12, left: 16, right: 16),
																						width: double.infinity,
																						  child: Row(
																							  crossAxisAlignment: CrossAxisAlignment.start,
																							  children: [
																								  IntrinsicWidth(
																									  child: IntrinsicHeight(
																										  child: Container(
																											  decoration: BoxDecoration(
																												  borderRadius: BorderRadius.only(
																													  topLeft: Radius.circular(12),
																													  bottomLeft: Radius.circular(12),
																												  ),
																												  color: Color(0xFFF4F2EF),
																											  ),
																											  padding: const EdgeInsets.only( top: 12, bottom: 12, left: 16),
																											  child: Column(
																												  crossAxisAlignment: CrossAxisAlignment.start,
																												  children: [
																													  Icon(Icons.search, color: Color(0xFF897060)),
																												  ]
																											  ),
																										  ),
																									  ),
																								  ),
																								  Expanded(
																									  child: IntrinsicHeight(
																										  child: Container(
																											  alignment: Alignment.center,
																											  decoration: BoxDecoration(
																												  borderRadius: BorderRadius.only(
																													  topRight: Radius.circular(12),
																													  bottomRight: Radius.circular(12),
																												  ),
																												  color: Color(0xFFF4F2EF),
																											  ),
																											  padding: const EdgeInsets.only( top: 12, bottom: 12, left: 8, right: 8),
																											  width: double.infinity,
																											  child: Row(
																												  children: [
																													  Expanded(
																														  child: TextField(
																															  style: TextStyle(
																																  color: Color(0xFF897060),
																																  fontSize: 16,
																															  ),
																															  onChanged: (value) { 
																																  setState(() { textField1 = value; });
																															  },
																															  decoration: InputDecoration(
																																  hintText: "Search  for artisans or crafts",
																																  isDense: true,
																																  contentPadding: EdgeInsets.symmetric(vertical: 0),
																																  border: InputBorder.none,
																															  ),
																														  ),
																													  ),
																													  Icon(Icons.mic, color: Color(0xFF897060)),
																												  ],
																											  ),
																										  ),
																									  ),
																								  ),
																							  ]
																						  ),
																					),
																				),
																				SlideTransition(
																				  position: _catOffsetAnimation,
																																									child: Container(
																																											padding: const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 12),
																																											width: double.infinity,
																																											child: SingleChildScrollView(
																																												scrollDirection: Axis.horizontal,
																																												child: Row(
																																													mainAxisAlignment: MainAxisAlignment.start,
																																													children: [
																																														_buildCategoryButton("Handloom"),
																																														SizedBox(width: 12),
																																														_buildCategoryButton("Pottery"),
																																														SizedBox(width: 12),
																																														_buildCategoryButton("Jewelry"),
																																														SizedBox(width: 12),
																																														_buildCategoryButton("Basketry"),
																																														SizedBox(width: 12),
																																														_buildCategoryButton("Woodcraft"),
																																														SizedBox(width: 12),
																																														_buildCategoryButton("Stonecraft"),
																																													],
																																												),
																																											),
																																										),
																				),
																				IntrinsicHeight(
																					child: Container(
																						padding: const EdgeInsets.all(16),
																						width: double.infinity,
																						child: Row(
																							crossAxisAlignment: CrossAxisAlignment.start,
																							children: [
																								Expanded(
																									child: IntrinsicHeight(
																										child: Container(
																											width: double.infinity,
																											child: Column(
																												crossAxisAlignment: CrossAxisAlignment.start,
																												children: [
																													IntrinsicHeight(
																														child: Container(
																															margin: const EdgeInsets.only( bottom: 16),
																															width: double.infinity,
																															child: Column(
																																crossAxisAlignment: CrossAxisAlignment.start,
																																children: [
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 5),
																																		child: Text(
																																			"Master Weaver",
																																			style: TextStyle(
																																				color: Color(0xFF897060),
																																				fontSize: 14,
																																			),
																																		),
																																	),
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 5),
																																		child: Text(
																																			"Anjali Sharma",
																																			style: TextStyle(
																																				color: Color(0xFF161411),
																																				fontSize: 16,
																																				fontWeight: FontWeight.bold,
																																			),
																																		),
																																	),
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 1),
																																		child: Text(
																																			"Handloom",
																																			style: TextStyle(
																																				color: Color(0xFF897060),
																																				fontSize: 14,
																																			),
																																		),
																																	),
																																]
																															),
																														),
																													),
																													InkWell(
																														onTap: () { print('Pressed'); },
																														child: IntrinsicWidth(
																															child: IntrinsicHeight(
																																child: Container(
																																	decoration: BoxDecoration(
																																		borderRadius: BorderRadius.circular(12),
																																		color: Color(0xFFF4F2EF),
																																	),
																																	padding: const EdgeInsets.only( top: 5, bottom: 5, left: 16, right: 16),
																																	child: Column(
																																		children: [
																																			Text(
																																				"Visit Showroom",
																																				style: TextStyle(
																																					color: Color(0xFF161411),
																																					fontSize: 14,
																																					fontWeight: FontWeight.bold,
																																				),
																																			),
																																		]
																																	),
																																),
																															),
																														),
																													),
																												]
																											),
																										),
																									),
																								),
																								Container(
																									decoration: BoxDecoration(
																										borderRadius: BorderRadius.circular(12),
																									),
																									width: 130,
																									height: 118,
																									child: ClipRRect(
																										borderRadius: BorderRadius.circular(12),
																										child: Image.network(
																											"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/S5Gz3UHxLl/hkobl7qr_expires_30_days.png",
																											fit: BoxFit.fill,
																										)
																									)
																								),
																							]
																						),
																					),
																				),
																				IntrinsicHeight(
																					child: Container(
																						padding: const EdgeInsets.all(16),
																						width: double.infinity,
																						child: Row(
																							crossAxisAlignment: CrossAxisAlignment.start,
																							children: [
																								Expanded(
																									child: IntrinsicHeight(
																										child: Container(
																											width: double.infinity,
																											child: Column(
																												crossAxisAlignment: CrossAxisAlignment.start,
																												children: [
																													IntrinsicHeight(
																														child: Container(
																															margin: const EdgeInsets.only( bottom: 16),
																															width: double.infinity,
																															child: Column(
																																crossAxisAlignment: CrossAxisAlignment.start,
																																children: [
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 5),
																																		child: Text(
																																			"Potter",
																																			style: TextStyle(
																																				color: Color(0xFF897060),
																																				fontSize: 14,
																																			),
																																		),
																																	),
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 5),
																																		child: Text(
																																			"Rohan Verma",
																																			style: TextStyle(
																																				color: Color(0xFF161411),
																																				fontSize: 16,
																																				fontWeight: FontWeight.bold,
																																			),
																																		),
																																	),
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 1),
																																		child: Text(
																																			"Pottery",
																																			style: TextStyle(
																																				color: Color(0xFF897060),
																																				fontSize: 14,
																																			),
																																		),
																																	),
																																]
																															),
																														),
																													),
																													InkWell(
																														onTap: () { print('Pressed'); },
																														child: IntrinsicWidth(
																															child: IntrinsicHeight(
																																child: Container(
																																	decoration: BoxDecoration(
																																		borderRadius: BorderRadius.circular(12),
																																		color: Color(0xFFF4F2EF),
																																	),
																																	padding: const EdgeInsets.only( top: 5, bottom: 5, left: 16, right: 16),
																																	child: Column(
																																		children: [
																																			Text(
																																				"Visit Showroom",
																																				style: TextStyle(
																																					color: Color(0xFF161411),
																																					fontSize: 14,
																																					fontWeight: FontWeight.bold,
																																				),
																																			),
																																		]
																																	),
																																),
																															),
																														),
																													),
																												]
																											),
																										),
																									),
																								),
																								Container(
																									decoration: BoxDecoration(
																										borderRadius: BorderRadius.circular(12),
																									),
																									width: 130,
																									height: 118,
																									child: ClipRRect(
																										borderRadius: BorderRadius.circular(12),
																										child: Image.network(
																											"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/S5Gz3UHxLl/fpfoc77r_expires_30_days.png",
																											fit: BoxFit.fill,
																										)
																									)
																								),
																							]
																						),
																					),
																				),
																				IntrinsicHeight(
																					child: Container(
																						padding: const EdgeInsets.all(16),
																						width: double.infinity,
																						child: Row(
																							crossAxisAlignment: CrossAxisAlignment.start,
																							children: [
																								Expanded(
																									child: IntrinsicHeight(
																										child: Container(
																											width: double.infinity,
																											child: Column(
																												crossAxisAlignment: CrossAxisAlignment.start,
																												children: [
																													IntrinsicHeight(
																														child: Container(
																															margin: const EdgeInsets.only( bottom: 16),
																															width: double.infinity,
																															child: Column(
																																crossAxisAlignment: CrossAxisAlignment.start,
																																children: [
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 5),
																																		child: Text(
																																			"Jeweler",
																																			style: TextStyle(
																																				color: Color(0xFF897060),
																																				fontSize: 14,
																																			),
																																		),
																																	),
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 5),
																																		child: Text(
																																			"Priya Kapoor",
																																			style: TextStyle(
																																				color: Color(0xFF161411),
																																				fontSize: 16,
																																				fontWeight: FontWeight.bold,
																																			),
																																		),
																																	),
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 1),
																																		child: Text(
																																			"Jewelry",
																																			style: TextStyle(
																																				color: Color(0xFF897060),
																																				fontSize: 14,
																																			),
																																		),
																																	),
																																]
																															),
																														),
																													),
																													InkWell(
																														onTap: () { print('Pressed'); },
																														child: IntrinsicWidth(
																															child: IntrinsicHeight(
																																child: Container(
																																	decoration: BoxDecoration(
																																		borderRadius: BorderRadius.circular(12),
																																		color: Color(0xFFF4F2EF),
																																	),
																																	padding: const EdgeInsets.only( top: 5, bottom: 5, left: 16, right: 16),
																																	child: Column(
																																		children: [
																																			Text(
																																				"Visit Showroom",
																																				style: TextStyle(
																																					color: Color(0xFF161411),
																																					fontSize: 14,
																																					fontWeight: FontWeight.bold,
																																				),
																																			),
																																		]
																																	),
																																),
																															),
																														),
																													),
																												]
																											),
																										),
																									),
																								),
																								Container(
																									decoration: BoxDecoration(
																										borderRadius: BorderRadius.circular(12),
																									),
																									width: 130,
																									height: 118,
																									child: ClipRRect(
																										borderRadius: BorderRadius.circular(12),
																										child: Image.network(
																											"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/S5Gz3UHxLl/3q1tkusk_expires_30_days.png",
																											fit: BoxFit.fill,
																										)
																									)
																								),
																							]
																						),
																					),
																				),
																				IntrinsicHeight(
																					child: Container(
																						padding: const EdgeInsets.all(16),
																						width: double.infinity,
																						child: Row(
																							crossAxisAlignment: CrossAxisAlignment.start,
																							children: [
																								Expanded(
																									child: IntrinsicHeight(
																										child: Container(
																											width: double.infinity,
																											child: Column(
																												crossAxisAlignment: CrossAxisAlignment.start,
																												children: [
																													IntrinsicHeight(
																														child: Container(
																															margin: const EdgeInsets.only( bottom: 16),
																															width: double.infinity,
																															child: Column(
																																crossAxisAlignment: CrossAxisAlignment.start,
																																children: [
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 5),
																																		child: Text(
																																			"Basket Maker",
																																			style: TextStyle(
																																				color: Color(0xFF897060),
																																				fontSize: 14,
																																			),
																																		),
																																	),
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 5),
																																		child: Text(
																																			"Arjun Singh",
																																			style: TextStyle(
																																				color: Color(0xFF161411),
																																				fontSize: 16,
																																				fontWeight: FontWeight.bold,
																																			),
																																		),
																																	),
																																	Container(
																																		margin: const EdgeInsets.only( bottom: 1),
																																		child: Text(
																																			"Basketry",
																																			style: TextStyle(
																																				color: Color(0xFF897060),
																																				fontSize: 14,
																																			),
																																		),
																																	),
																																]
																															),
																														),
																													),
																													InkWell(
																														onTap: () { print('Pressed'); },
																														child: IntrinsicWidth(
																															child: IntrinsicHeight(
																																child: Container(
																																	decoration: BoxDecoration(
																																		borderRadius: BorderRadius.circular(12),
																																		color: Color(0xFFF4F2EF),
																																	),
																																	padding: const EdgeInsets.only( top: 5, bottom: 5, left: 16, right: 16),
																																	child: Column(
																																		children: [
																																			Text(
																																				"Visit Showroom",
																																				style: TextStyle(
																																					color: Color(0xFF161411),
																																					fontSize: 14,
																																					fontWeight: FontWeight.bold,
																																				),
																																			),
																																		]
																																	),
																																),
																															),
																														),
																													),
																												]
																											),
																										),
																									),
																								),
																								Container(
																									decoration: BoxDecoration(
																										borderRadius: BorderRadius.circular(12),
																									),
																									width: 130,
																									height: 118,
																									child: ClipRRect(
																										borderRadius: BorderRadius.circular(12),
																										child: Image.network(
																											"https://storage.googleapis.com/tagjs-prod.appspot.com/v1/S5Gz3UHxLl/9l0p29x0_expires_30_days.png",
																											fit: BoxFit.fill,
																										)
																									)
																								),
																							]
																						),
																					),
																				),
																			]
																		),
																	),
																),
																IntrinsicHeight(
																	child: Container(
																		width: double.infinity,
																		child: Column(
																			crossAxisAlignment: CrossAxisAlignment.start,
																			children: [
																				   IntrinsicHeight(
																					  child: Container(
																						  color: Color(0xFFFFFFFF),
																						  padding: const EdgeInsets.only( top: 9, bottom: 9, left: 16, right: 16),
																						  width: double.infinity,
																						  child: Row(
																							  crossAxisAlignment: CrossAxisAlignment.start,
																							  children: [
																								  Expanded(
																									  child: InkWell(
																										  onTap: () {
																											  Navigator.pop(context);
																										  },
																										  child: Column(
																											  mainAxisAlignment: MainAxisAlignment.center,
																											  children: [
																												  Icon(Icons.home_outlined, color: Colors.black54, size: 28),
																												  Text(
																													  "Home",
																													  style: TextStyle(
																														  color: Colors.black54,
																														  fontSize: 12,
																														  fontWeight: FontWeight.bold,
																													  ),
																												  ),
																											  ],
																										  ),
																									  ),
																								  ),
																								  Expanded(
																									  child: Column(
																										  mainAxisAlignment: MainAxisAlignment.center,
																										  children: [
																											  Icon(Icons.search, color: Color(0xFF4B3426), size: 28),
																											  Text(
																												  "Explore",
																												  style: TextStyle(
																													  color: Color(0xFF4B3426),
																													  fontSize: 12,
																													  fontWeight: FontWeight.bold,
																												  ),
																											  ),
																										  ],
																									  ),
																								  ),
																								  Expanded(
																									  child: Column(
																										  mainAxisAlignment: MainAxisAlignment.center,
																										  children: [
																											  Icon(Icons.person_outline, color: Colors.black54, size: 28),
																											  Text(
																												  "Profile",
																												  style: TextStyle(
																													  color: Colors.black54,
																													  fontSize: 12,
																													  fontWeight: FontWeight.bold,
																												  ),
																											  ),
																										  ],
																									  ),
																								  ),
																							  ],
																						  ),
																					  ),
																				  ),
																				Container(
																					color: Color(0xFFFFFFFF),
																					height: 20,
																					width: double.infinity,
																					child: SizedBox(),
																				),
																			]
																		),
																	),
																),
															]
														),
													),
												),
											],
										)
									),
								),
							),
						],
					),
				),
			),
		);
	}
}