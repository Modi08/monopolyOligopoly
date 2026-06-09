import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/actioncards.dart';
import 'package:monopolyoligarch/components/avatarcirclecard.dart';
import 'package:monopolyoligarch/services/database/models.dart';

class Dashboard extends StatefulWidget {
  final double width;
  final double height;
  final Player currentPlayer;
  const Dashboard({
    super.key,
    required this.width,
    required this.height,
    required this.currentPlayer,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

void transferCash() {
  debugPrint("Transfer Cash");
}

void issueLoan() {
  debugPrint("Issue Loan");
}

void requestLoan() {
  debugPrint("Request Loan");
}

void issueDiscountTokens() {
  debugPrint("issueDiscountTokens");
}

void startTrade() {
  debugPrint("Trade Started");
}

void rentOut() {
  debugPrint("Rented Out");
}

class _DashboardState extends State<Dashboard> {
  List<List<dynamic>> actionsLists = [
    [Icons.payments_rounded, "Transfer Cash", transferCash],
    [Icons.account_balance_rounded, "Issue Loan", issueLoan],
    [Icons.request_quote_rounded, "Request Loan", requestLoan],
    [Icons.discount_rounded, "Issue Discount", issueDiscountTokens],
    [Icons.currency_exchange_rounded, "Start Trade", startTrade],
    [Icons.real_estate_agent_rounded, "Rent Out", rentOut],
  ];
  List<Widget> actionCardsLists = [];

  List<Widget> buildActionCardsList() {
    return actionsLists.map((actionElements) {
      return ActionCard(
        height: widget.height,
        width: widget.width,
        iconSymbol: actionElements[0],
        action: actionElements[1],
        actionFunction: actionElements[2],
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      actionCardsLists = buildActionCardsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.width * 0.075),
      child: Column(
        spacing: widget.height * 0.01,
        children: [
          SizedBox(height: widget.height * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: widget.width * 0.075,

            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Executive Overview", style: theme.textTheme.bodyMedium),
                  Text(
                    "Welcome, ${widget.currentPlayer.name}",
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              AvatarCircleCard(
                height: widget.height,
                width: widget.width,
                username: widget.currentPlayer.name,
              ),
            ],
          ),
          SizedBox(height: widget.height * 0.025),
          Container(
            width: widget.width * 0.85,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                stops: [0, 1],
                begin: AlignmentDirectional(0, -1),
                end: AlignmentDirectional(0, 1),
              ),
              borderRadius: BorderRadius.circular(32),
              shape: BoxShape.rectangle,
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.width * 0.075),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: widget.height * 0.0075,
                children: [
                  Text(
                    "Total Net Worth",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: const Color.fromARGB(255, 253, 241, 241),
                    ),
                  ),
                  Text(
                    "\$${widget.currentPlayer.netWorth}",
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      Icon(Icons.trending_up),
                      Text(
                        "Percentage change from last turn",
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: widget.height * 0.025),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(32),
              shape: BoxShape.rectangle,
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Liquid Cash", style: theme.textTheme.bodyMedium),

                      Text(
                        "\$${widget.currentPlayer.cash}",
                        style: theme.textTheme.titleLarge!.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.account_balance_wallet_rounded),
                ],
              ),
            ),
          ),
          SizedBox(height: widget.height * 0.005),
          Text("Strategic Actions", style: theme.textTheme.bodyMedium),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: widget.width * 0.05,
              children: actionCardsLists,
            ),
          ),
          SizedBox(height: widget.height * 0.015),
          Row(
            children: [
              Text(
                "Urgent Alerts",
                style: theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "2 ACTIVE",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
