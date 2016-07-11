PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE "tags" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255));
CREATE TABLE "tags_tasks" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "task_id" integer NOT NULL, "tag_id" integer NOT NULL);
INSERT INTO "tags_tasks" VALUES(1,1,2);
CREATE TABLE "categories" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255));
INSERT INTO "categories" VALUES(1,'task');
INSERT INTO "categories" VALUES(2,'diary');
INSERT INTO "categories" VALUES(3,'worktask');
INSERT INTO "categories" VALUES(4,'workdiary');
CREATE TABLE "parent_relationships" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "parent_id" int, "child_id" int);
INSERT INTO "parent_relationships" VALUES(1,2,1);
INSERT INTO "parent_relationships" VALUES(2,12,1);
INSERT INTO "parent_relationships" VALUES(3,61,55);
INSERT INTO "parent_relationships" VALUES(4,193,191);
INSERT INTO "parent_relationships" VALUES(5,194,191);
INSERT INTO "parent_relationships" VALUES(6,195,191);
CREATE TABLE "tasks" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "parent_id" int, "due" datetime, "start" datetime, "expcomplete" datetime, "completed" datetime, "category_id" integer, "entry" varchar(255));
INSERT INTO "tasks" VALUES(136,NULL,'2011-02-28','2011-03-01 09:04:53','2011-02-28 00:00:00','2011-03-01 10:24:18',1,'Get Computer up and Running');
INSERT INTO "tasks" VALUES(137,NULL,NULL,'2011-03-01 09:05:11',NULL,NULL,4,'Arrived to work');
INSERT INTO "tasks" VALUES(138,NULL,NULL,'2011-03-01 09:07:07',NULL,NULL,4,'finding files for latex / documentation');
INSERT INTO "tasks" VALUES(139,NULL,NULL,'2011-03-01 09:11:15',NULL,NULL,4,'Arrived to work at 8:59');
INSERT INTO "tasks" VALUES(140,NULL,NULL,'2011-03-01 09:24:06',NULL,NULL,4,'Tried to send an email to the sys people. It failed.
Worked with Jeremy to try to submit an email to systems_help. It failed.
Goal was to submit an email to the Systems group to gain access to the subversion repository');
INSERT INTO "tasks" VALUES(141,NULL,NULL,'2011-03-01 10:17:23',NULL,NULL,4,'Bill helped setup my computer system. It is now working for email, 
Waiting to hear back on the subversion server');
INSERT INTO "tasks" VALUES(142,NULL,NULL,'2011-03-01 10:23:45',NULL,NULL,4,'Web page of 
https://confluence.abraxas1.com/display/NT/New+Developer+Guide
Contains the list of various development setup routines');
INSERT INTO "tasks" VALUES(143,NULL,NULL,'2011-03-01 10:28:40',NULL,NULL,4,'Setting up development / kerberos according to the web document');
INSERT INTO "tasks" VALUES(144,NULL,NULL,'2011-03-01 10:41:05',NULL,NULL,4,'Got Cart definition file
https://confluence.abraxas1.com/display/doc/Consumer+Cart+Design
');
INSERT INTO "tasks" VALUES(145,NULL,NULL,'2011-03-01 10:41:14',NULL,NULL,4,'Cart');
INSERT INTO "tasks" VALUES(146,NULL,NULL,'2011-03-01 11:20:07',NULL,NULL,4,'Developing plan for pulling out Perl calls from Mason 
files');
INSERT INTO "tasks" VALUES(147,NULL,NULL,'2011-03-01 13:39:58',NULL,NULL,4,'Trying out Bill''s strategy for using HTML::Mason::Compiler as 
a means for compiling the Mason files');
INSERT INTO "tasks" VALUES(148,NULL,NULL,'2011-03-01 14:55:30',NULL,NULL,4,'Continuing with Subclass of HTML::Mason::Lexer class');
INSERT INTO "tasks" VALUES(149,NULL,NULL,'2011-03-01 15:01:47',NULL,NULL,4,'l');
INSERT INTO "tasks" VALUES(150,NULL,NULL,'2011-03-01 15:02:13',NULL,NULL,4,'Figuring out how to pass a new lExer as an argument 
to the tool that does the construction');
INSERT INTO "tasks" VALUES(151,NULL,NULL,'2011-03-01 16:11:51',NULL,NULL,4,'Finding that Lexer class doesn''t really provide that much good stuff');
INSERT INTO "tasks" VALUES(152,NULL,NULL,'2011-03-01 16:44:40',NULL,NULL,4,'Was able to temp hack the API so that I can record the matches');
INSERT INTO "tasks" VALUES(153,NULL,NULL,'2011-03-01 17:11:46',NULL,NULL,4,'Adding finishing touches to the parsing elements>
Currently I can parse files, but I need a way to recover in cases of errors');
INSERT INTO "tasks" VALUES(154,NULL,'2011-03-02','2011-03-01 17:13:10','2011-03-02 00:00:00','2011-03-02 16:53:22',1,'Get Mason Parser Finished');
INSERT INTO "tasks" VALUES(155,NULL,NULL,'2011-03-02 08:55:19',NULL,NULL,4,'Arrived to work');
INSERT INTO "tasks" VALUES(156,NULL,NULL,'2011-03-02 09:03:13',NULL,NULL,4,'Adding finishing touches to the parsing elements>
Currently I can parse files, but I need a way to recover in cases of errors

');
INSERT INTO "tasks" VALUES(157,NULL,NULL,'2011-03-02 14:26:29',NULL,NULL,4,'Trying to get a simple git system working>

IT didn''t setup the server so that I am able to download.
Trying to use a shared Git file on the network');
INSERT INTO "tasks" VALUES(158,NULL,NULL,'2011-03-02 16:52:47',NULL,NULL,4,'Working on Git . Coming up to speed with using it, branching etc...');
INSERT INTO "tasks" VALUES(159,NULL,NULL,'2011-03-03 09:22:46',NULL,NULL,4,'Arrived to Work');
INSERT INTO "tasks" VALUES(160,NULL,NULL,'2011-03-03 09:57:06',NULL,NULL,4,'Working on releasing tools to the branches');
INSERT INTO "tasks" VALUES(161,NULL,NULL,'2011-03-03 12:59:22',NULL,NULL,4,'Got an example with Moose working. Has great ability to add code before and after accessors');
INSERT INTO "tasks" VALUES(162,NULL,'2011-03-04','2011-03-03 13:00:03','2011-03-04 00:00:00','2011-03-16 08:33:54',1,'Disambiguator script');
INSERT INTO "tasks" VALUES(163,NULL,'2011-03-03','2011-03-03 13:00:18','2011-03-03 00:00:00','2011-03-07 12:00:52',1,'Help out Jim / Bill with Git pushing/ pulling');
INSERT INTO "tasks" VALUES(164,NULL,NULL,'2011-03-04 09:27:47',NULL,NULL,4,'Arrived to work at 8:30
');
INSERT INTO "tasks" VALUES(165,NULL,NULL,'2011-03-04 09:56:48',NULL,NULL,4,'Looking for add_subscription');
INSERT INTO "tasks" VALUES(166,NULL,NULL,'2011-03-07 09:18:16',NULL,NULL,4,'Arrived to work 9:00 am');
INSERT INTO "tasks" VALUES(167,NULL,NULL,'2011-03-07 09:19:18',NULL,NULL,4,'Have to continue removing ambiguities from the source calls');
INSERT INTO "tasks" VALUES(168,NULL,NULL,'2011-03-07 11:59:46',NULL,NULL,4,'Looking at source code under https://svn.ais.anoneng.com/repo/common/lib/trunk/');
INSERT INTO "tasks" VALUES(169,NULL,NULL,'2011-03-07 12:17:40',NULL,NULL,4,'Which machine do we build on ? A consumer web build server');
INSERT INTO "tasks" VALUES(170,NULL,NULL,'2011-03-07 12:18:22',NULL,NULL,4,'Build scripts are under  svn co https://svn.ais.anoneng.com/repo/dev_build');
INSERT INTO "tasks" VALUES(171,NULL,NULL,'2011-03-08 08:33:22',NULL,NULL,4,'Arrived at work 7:45');
INSERT INTO "tasks" VALUES(172,NULL,NULL,'2011-03-08 08:34:24',NULL,NULL,4,'Examining the structure of code for the display diagrams');
INSERT INTO "tasks" VALUES(173,NULL,NULL,'2011-03-09 09:58:28',NULL,NULL,4,'Arrived to work at 8:30');
INSERT INTO "tasks" VALUES(174,NULL,'2011-03-09','2011-03-09 09:58:59','2011-03-09 00:00:00','2011-03-17 11:51:11',1,'Finish object disambiguator');
INSERT INTO "tasks" VALUES(175,NULL,NULL,'2011-03-10 10:26:52',NULL,NULL,4,'Arrived to work at 8:28am');
INSERT INTO "tasks" VALUES(176,NULL,NULL,'2011-03-10 11:27:49',NULL,NULL,4,'Working on task break up');
INSERT INTO "tasks" VALUES(177,NULL,NULL,'2011-03-10 11:40:36',NULL,NULL,4,'Need to find out who calls add_subscription()');
INSERT INTO "tasks" VALUES(178,NULL,NULL,'2011-03-10 14:44:08',NULL,NULL,4,'Investigating Perl webservice calls');
INSERT INTO "tasks" VALUES(179,NULL,NULL,'2011-03-10 16:17:42',NULL,NULL,4,'Bill suggested using Wddx as an interface tool');
INSERT INTO "tasks" VALUES(180,NULL,NULL,'2011-03-11 08:02:39',NULL,NULL,4,'Arrived to work at 8:00');
INSERT INTO "tasks" VALUES(181,NULL,NULL,'2011-03-11 09:14:42',NULL,NULL,4,'Jeremy sent the login credentials for the Aria general account.
It is the password with start123.  

In addition, it has a page that contains the authorization key for connecting');
INSERT INTO "tasks" VALUES(182,NULL,NULL,'2011-03-11 13:31:59',NULL,NULL,4,'Need to try out the disambiguator  code one more time');
INSERT INTO "tasks" VALUES(183,NULL,NULL,'2011-03-14 08:58:33',NULL,NULL,4,'Arrive to work at 8:45');
INSERT INTO "tasks" VALUES(184,NULL,'2011-03-14','2011-03-14 08:59:37','2011-03-14 00:00:00','2011-03-16 08:34:01',1,'Generate disambiguated code');
INSERT INTO "tasks" VALUES(186,NULL,NULL,'2011-03-15 07:56:15',NULL,NULL,4,'Arrived to work at 7:35');
INSERT INTO "tasks" VALUES(187,NULL,NULL,'2011-03-15 08:29:48',NULL,NULL,4,'Trying to figure out if there is a way to delete records on the Aria side');
INSERT INTO "tasks" VALUES(188,NULL,NULL,'2011-03-15 09:43:36',NULL,NULL,4,'Creating the spec for the Aria Adapter');
INSERT INTO "tasks" VALUES(189,NULL,NULL,'2011-03-16 08:33:29',NULL,NULL,4,'Arrived to work at 8:30');
INSERT INTO "tasks" VALUES(190,NULL,NULL,'2011-03-17 11:50:44',NULL,NULL,4,'Arrived to work at 8:50');
INSERT INTO "tasks" VALUES(191,NULL,'2011-03-15','2011-03-17 11:54:36','2011-03-18 00:00:00','2011-03-28 14:31:53',1,'Anonymizer::Account::Act definition plus Module');
INSERT INTO "tasks" VALUES(192,NULL,NULL,'2011-03-17 11:55:30',NULL,NULL,4,'Creating subtasks for my project');
INSERT INTO "tasks" VALUES(193,NULL,'2011-03-17','2011-03-17 11:58:12','2011-03-17 00:00:00','2011-03-28 14:31:47',1,'Nail down SQL definition for ''Account''');
INSERT INTO "tasks" VALUES(194,NULL,'2011-03-17','2011-03-17 11:59:34','2011-03-17 00:00:00','2011-03-22 10:52:16',1,'Write Anonymizer::Account::Act definition to pull out the correct query');
INSERT INTO "tasks" VALUES(195,NULL,'2011-03-17','2011-03-17 12:00:01','2011-03-17 00:00:00','2011-03-22 10:52:11',1,'Define the methods that will determine if two Anonymizer::Account s are equivalent');
INSERT INTO "tasks" VALUES(196,NULL,NULL,'2011-03-18 15:53:48',NULL,NULL,4,'Getting code from Jeremy again, putting it into temporary location');
INSERT INTO "tasks" VALUES(197,NULL,NULL,'2011-03-21 10:05:00',NULL,NULL,4,'Arrived to work at 9:15');
INSERT INTO "tasks" VALUES(198,NULL,NULL,'2011-03-21 10:07:24',NULL,NULL,4,'Need to get Jeremy''s script, Store it in a good location:

/Users/jdamon/Dropbox/Projects/Work/Aria/tools/bin/jeremy_example.pl

');
INSERT INTO "tasks" VALUES(201,NULL,NULL,'2011-03-21 11:52:08',NULL,NULL,4,'Looking at Rspec added comments for the Testcases');
INSERT INTO "tasks" VALUES(203,NULL,NULL,'2011-03-21 11:54:11',NULL,NULL,4,'Integration test: Testing groups of modules of software

Systems test: includes black box testing, and it represents end to end testing');
INSERT INTO "tasks" VALUES(204,NULL,NULL,'2011-03-21 11:58:40',NULL,NULL,4,'I am testing the following parts of the account interface


set_key_for_value
keys
value_for_key
is_equal
');
INSERT INTO "tasks" VALUES(205,NULL,NULL,'2011-03-21 16:47:39',NULL,NULL,4,'Also added a method for the AccountInterface which is ''record_keys'' ');
INSERT INTO "tasks" VALUES(206,NULL,NULL,'2011-03-22 10:51:17',NULL,NULL,4,'Arrived to work at 9:48');
INSERT INTO "tasks" VALUES(207,NULL,NULL,'2011-03-23 10:18:24',NULL,NULL,4,'Arrived to work at 8:54');
INSERT INTO "tasks" VALUES(208,NULL,NULL,'2011-03-23 15:56:35',NULL,NULL,4,'verify that AccountInterface is enforced for Account objects
Verify that Interface methods verify correct things
Verify that we can Cast objects to other types');
INSERT INTO "tasks" VALUES(209,NULL,NULL,'2011-03-23 15:56:55',NULL,NULL,4,'Working on testcase to push data
into Aria');
INSERT INTO "tasks" VALUES(210,NULL,NULL,'2011-03-24 07:54:02',NULL,NULL,4,'Arrived to work at 7:35');
INSERT INTO "tasks" VALUES(211,NULL,NULL,'2011-03-24 08:31:56',NULL,NULL,4,'Working on testcases for the Jeremy / Aria posting ');
INSERT INTO "tasks" VALUES(214,NULL,NULL,'2011-03-24 13:52:42',NULL,NULL,4,'Need to figure out how to generate
large diagrams using 
doxygen');
INSERT INTO "tasks" VALUES(215,NULL,NULL,'2011-03-25 10:03:30',NULL,NULL,4,'Arrived to work 9:36');
INSERT INTO "tasks" VALUES(216,NULL,'2011-03-22','2011-03-25 10:29:22','2011-03-21 00:00:00','2011-03-28 14:31:40',1,'Identify error condition for posting to Aria');
INSERT INTO "tasks" VALUES(218,NULL,NULL,'2011-03-28 09:45:10',NULL,NULL,4,'Arrived to work at 9:20');
INSERT INTO "tasks" VALUES(219,NULL,NULL,'2011-03-28 09:45:31',NULL,NULL,4,'Create test itereations that repeatedly insert fields into Aria');
INSERT INTO "tasks" VALUES(220,NULL,NULL,'2011-03-28 10:39:40',NULL,NULL,4,'Website for all of the events is
https://admintools.future.stage.ariasystems.net/AdminTools.php/WebserviceAdministration/viewApiLog

Tags:
Event Log , Aria , Api
');
INSERT INTO "tasks" VALUES(221,NULL,NULL,'2011-03-28 10:43:49',NULL,NULL,4,'Issues related to posting new values were related completely to the change of the external IP address');
INSERT INTO "tasks" VALUES(222,NULL,NULL,'2011-03-28 11:46:25',NULL,NULL,4,'Able to search for Test Aria Account user, it is 

jimi_test20101130_new

The account number was 
2264591
');
INSERT INTO "tasks" VALUES(223,NULL,NULL,'2011-03-28 13:37:29',NULL,NULL,4,'Refactoring Jeremy''s example, 
Using Moose, replacing url and optional args with constants.
going to run the tests again');
INSERT INTO "tasks" VALUES(224,NULL,NULL,'2011-03-28 14:03:11',NULL,NULL,4,'Is a ''user_id'' required for performing a basic query against Aria');
INSERT INTO "tasks" VALUES(225,NULL,NULL,'2011-03-28 14:30:23',NULL,NULL,4,'Able to correctly query the Database on the 
Aria side and retrieve values');
INSERT INTO "tasks" VALUES(226,NULL,NULL,'2011-03-28 14:53:23',NULL,NULL,4,'Investigating how to add an attribute to mark a field as either deleted or something else ');
INSERT INTO "tasks" VALUES(227,NULL,NULL,'2011-03-28 15:06:24',NULL,NULL,4,'Aria Web page to display accounts

https://admintools.future.stage.ariasystems.net/AdminTools.php/Accounts/show

');
INSERT INTO "tasks" VALUES(228,NULL,NULL,'2011-03-28 16:30:23',NULL,NULL,4,'Looks like we have two urls that are important

https://secure.ariasystems.net/api/AriaQuery/objects.php

and 

https://stage.ariasystems.net/api/ws/api_ws_class_dispatcher.php
');
INSERT INTO "tasks" VALUES(229,NULL,NULL,'2011-03-28 18:26:27',NULL,NULL,4,'Had to hack the wddx parser, using patch in downloads');
INSERT INTO "tasks" VALUES(230,NULL,NULL,'2011-03-29 08:48:23',NULL,NULL,4,'Arrived to work at 8:30');
INSERT INTO "tasks" VALUES(232,NULL,'2011-03-29','2011-03-29 09:52:06','2011-03-29 00:00:00','2011-06-02 09:16:39',1,'Create update test');
INSERT INTO "tasks" VALUES(233,NULL,'2011-03-29','2011-03-29 09:56:15','2011-03-29 00:00:00','2011-03-29 14:15:18',1,'Read entry from Aria based on ''userid''');
INSERT INTO "tasks" VALUES(234,NULL,NULL,'2011-03-29 09:56:43',NULL,NULL,4,'The current task get_acct_no_from_user_id is failing');
INSERT INTO "tasks" VALUES(235,NULL,NULL,'2011-03-29 10:54:53',NULL,NULL,4,'Can read all of the fields of an account with
get_acct_details_all');
INSERT INTO "tasks" VALUES(236,NULL,NULL,'2011-03-29 10:55:29',NULL,NULL,4,'Working on understanding parts of the account fields

Looks like I will have to put a wrapper around the Account so that we 
know which parts of the fields we will be modifying
');
INSERT INTO "tasks" VALUES(237,NULL,NULL,'2011-03-30 07:32:10',NULL,NULL,4,'Arrived to work at 7:30');
INSERT INTO "tasks" VALUES(238,NULL,'2011-03-30','2011-03-30 07:32:49','2011-03-30 00:00:00','2011-04-01 09:51:54',1,'Update Addtasks');
INSERT INTO "tasks" VALUES(239,NULL,NULL,'2011-03-30 07:38:04',NULL,NULL,4,'Tasks are a bit silly');
INSERT INTO "tasks" VALUES(240,NULL,NULL,'2011-03-30 07:54:57',NULL,NULL,4,'Got past issue with Autoloading');
INSERT INTO "tasks" VALUES(241,NULL,NULL,'2011-03-30 08:47:50',NULL,NULL,4,'Back on the updating function...

Need to update a record on Aria');
INSERT INTO "tasks" VALUES(242,NULL,'2011-03-30','2011-03-30 08:48:15','2011-03-30 00:00:00','2011-04-13 07:47:28',1,'Add ability to mark a record as deleted');
INSERT INTO "tasks" VALUES(243,NULL,NULL,'2011-03-30 12:10:41',NULL,NULL,4,'Got sidetracked
Issue is that during an update we get back fields that are different than those that are submitted.

A better system is to wrap the return code from update_acct_complete, and then
translate it back');
INSERT INTO "tasks" VALUES(244,NULL,NULL,'2011-03-31 09:16:07',NULL,NULL,4,'Arrived to work at 9:10');
INSERT INTO "tasks" VALUES(245,NULL,NULL,'2011-03-31 10:39:31',NULL,NULL,4,'Trying to figure out issues with Multimethods');
INSERT INTO "tasks" VALUES(250,NULL,NULL,'2011-03-31 11:30:58',NULL,NULL,4,'Problem with the multi-methods was 


That you have to pass in the first argument as well

->mmethod( $a, $b ) is not the same as mmethod( $foo, $a, $b )
');
INSERT INTO "tasks" VALUES(251,NULL,NULL,'2011-03-31 13:46:25',NULL,NULL,4,'Working on unit test cases in this order
1. Create a generic Aria account object ( locally ) 
2. Take that account and make it active on the Aria side of things
3. Now update the final account
');
INSERT INTO "tasks" VALUES(252,NULL,NULL,'2011-04-01 09:52:10',NULL,NULL,4,'Arrived to work at 9:15');
INSERT INTO "tasks" VALUES(253,NULL,NULL,'2011-04-01 10:21:40',NULL,NULL,4,'Working on update, but also deciding on whether
to implment a Qualified Account class for objects that have been filled out');
INSERT INTO "tasks" VALUES(254,NULL,NULL,'2011-04-01 17:22:08',NULL,NULL,4,'Need to translate the fields from get_acct_details_all
into the format that could be resubmitted again');
INSERT INTO "tasks" VALUES(255,NULL,NULL,'2011-04-04 09:34:58',NULL,NULL,4,'Arrive to work at 9:24');
INSERT INTO "tasks" VALUES(256,NULL,'2011-04-04','2011-04-04 11:18:25','2011-04-04 00:00:00','2011-04-06 08:52:52',1,'Add comments to tests');
INSERT INTO "tasks" VALUES(257,NULL,NULL,'2011-04-04 18:55:09',NULL,NULL,4,'Fixing a standalone test case that can push a field to Aria');
INSERT INTO "tasks" VALUES(258,NULL,NULL,'2011-04-05 07:35:53',NULL,NULL,4,'Arrived to work at 7:30');
INSERT INTO "tasks" VALUES(259,NULL,NULL,'2011-04-05 07:36:00',NULL,NULL,4,'Finding a good tea place in San Diego');
INSERT INTO "tasks" VALUES(260,NULL,NULL,'2011-04-05 07:47:42',NULL,NULL,4,'Found a cool cafe...Cafe Bassam');
INSERT INTO "tasks" VALUES(261,NULL,NULL,'2011-04-05 08:02:59',NULL,NULL,4,'Just added some more hours to tasks');
INSERT INTO "tasks" VALUES(262,NULL,NULL,'2011-04-05 10:29:59',NULL,NULL,4,'Added ability to return fields with dereferencing
using Moose..This helps me keep the encapsulation that i want 
and allows me to not have to write the iterator');
INSERT INTO "tasks" VALUES(263,NULL,'2011-04-06','2011-04-05 10:42:07','2011-04-05 00:00:00','2011-05-10 14:48:16',1,'Create module to handle testing versus production');
INSERT INTO "tasks" VALUES(264,NULL,NULL,'2011-04-06 08:19:41',NULL,NULL,4,'Arrived to work at 8:03');
INSERT INTO "tasks" VALUES(265,NULL,NULL,'2011-04-06 09:40:54',NULL,NULL,4,'Got some more test cases working..

planning course of testing action for adding entries to Aria and then working with them');
INSERT INTO "tasks" VALUES(266,NULL,NULL,'2011-04-06 11:48:19',NULL,NULL,4,'Investigating whether we can do keyword expansion with Git...but
it''s not that necessary');
INSERT INTO "tasks" VALUES(267,NULL,NULL,'2011-04-08 12:41:52',NULL,NULL,4,'Arrived to work at 9:45');
INSERT INTO "tasks" VALUES(268,NULL,NULL,'2011-04-08 12:42:24',NULL,NULL,4,'Completed version of account 
so that I can just do a simple find, or find_all command 
and then change the type of argument
that I want to pass in as time progresses');
INSERT INTO "tasks" VALUES(269,NULL,NULL,'2011-04-11 08:09:47',NULL,NULL,4,'Arrived to work at 7:45');
INSERT INTO "tasks" VALUES(270,NULL,NULL,'2011-04-11 13:13:50',NULL,NULL,4,'Looking through documentation
to find out 
how to add the supplemental information for an account');
INSERT INTO "tasks" VALUES(271,NULL,NULL,'2011-04-12 08:39:49',NULL,NULL,4,'Arrived to work 7:50');
INSERT INTO "tasks" VALUES(272,NULL,NULL,'2011-04-13 07:47:04',NULL,NULL,4,'Arrived to work at 7:20');
INSERT INTO "tasks" VALUES(273,NULL,NULL,'2011-04-13 09:19:56',NULL,NULL,4,'Making fixes to the translation tool. It is leaving out
 a lot of fields');
INSERT INTO "tasks" VALUES(274,NULL,NULL,'2011-04-13 10:06:44',NULL,NULL,4,'Trying to lean how to recover my changes');
INSERT INTO "tasks" VALUES(275,NULL,NULL,'2011-04-18 17:16:42',NULL,NULL,4,'Arrived to work at 2:10pm');
INSERT INTO "tasks" VALUES(276,NULL,NULL,'2011-04-18 17:17:08',NULL,NULL,4,'Writing test cases to compare a BillingGroup readback from Aria and a billinggroup that was created from scratch');
INSERT INTO "tasks" VALUES(277,NULL,NULL,'2011-04-19 11:38:07',NULL,NULL,4,'Arrived to work at 7:20');
INSERT INTO "tasks" VALUES(278,NULL,NULL,'2011-04-19 11:38:22',NULL,NULL,4,'Working on testcases that do comparissons of account types');
INSERT INTO "tasks" VALUES(279,NULL,'2011-04-19','2011-04-19 11:39:34','2011-04-19 14:00:00','2011-04-21 10:15:03',1,'Get many to one mapping work');
INSERT INTO "tasks" VALUES(280,NULL,NULL,'2011-04-20 07:49:42',NULL,NULL,4,'Arrived to work at 7:38');
INSERT INTO "tasks" VALUES(281,NULL,NULL,'2011-04-21 10:14:42',NULL,NULL,4,'Arrived to work at 8:10');
INSERT INTO "tasks" VALUES(282,NULL,NULL,'2011-04-25 10:25:17',NULL,NULL,4,'Arrived to work at 8:05');
INSERT INTO "tasks" VALUES(283,NULL,NULL,'2011-04-25 10:25:40',NULL,NULL,4,'Writing testcases for Bill . Figured out that we need to first load the scenario 
and then call one of his methods to verify that the data was indeed correct');
INSERT INTO "tasks" VALUES(284,NULL,NULL,'2011-04-25 13:46:54',NULL,NULL,4,'Spoke with Bill. Got some better input as to what he needed for his test cases');
INSERT INTO "tasks" VALUES(285,NULL,NULL,'2011-04-25 13:47:09',NULL,NULL,4,'Going to make the changes to Bill''s testcases now');
INSERT INTO "tasks" VALUES(286,NULL,NULL,'2011-04-26 08:49:32',NULL,NULL,4,'Arrived to work at 8:35');
INSERT INTO "tasks" VALUES(287,NULL,NULL,'2011-04-26 08:49:47',NULL,NULL,4,'Testing Bill''s code ...implementing unit test cases');
INSERT INTO "tasks" VALUES(288,NULL,NULL,'2011-04-27 10:12:33',NULL,NULL,4,'Arrived to work at 8:05');
INSERT INTO "tasks" VALUES(289,NULL,NULL,'2011-04-27 10:12:50',NULL,NULL,4,'Writing test cases and code modifications to Bill''s Util.pm');
INSERT INTO "tasks" VALUES(290,NULL,NULL,'2011-04-27 11:53:28',NULL,NULL,4,'Fixing Bill''s Util.pm so that it 
doesn''t throw an exception');
INSERT INTO "tasks" VALUES(291,NULL,NULL,'2011-04-27 14:14:01',NULL,NULL,4,'Completed testcaes for Bill');
INSERT INTO "tasks" VALUES(292,NULL,NULL,'2011-04-28 08:27:25',NULL,NULL,4,'Arrived to work at 8:00');
INSERT INTO "tasks" VALUES(293,NULL,NULL,'2011-04-28 08:45:51',NULL,NULL,4,'Status of tests
Test Summary Report
-------------------
tests/t/query_account_verify_fields.t             (Wstat: 512 Tests: 21 Failed: 2)
  Failed tests:  20-21
  Non-zero exit status: 2
  Parse errors: Bad plan.  You planned 20 tests but ran 21.
tests/t/translate_act_to_aria.t                   (Wstat: 512 Tests: 20 Failed: 2)
  Failed tests:  11-12
  Non-zero exit status: 2
tests/t/translate_read_aria_record_to_aria.t      (Wstat: 65280 Tests: 12 Failed: 7)
  Failed tests:  6-12
  Non-zero exit status: 255
tests/t/update_account.t                          (Wstat: 512 Tests: 14 Failed: 2)
  Failed tests:  12, 14
  Non-zero exit status: 2
  Parse errors: Bad plan.  You planned 16 tests but ran 14.
');
INSERT INTO "tasks" VALUES(294,NULL,NULL,'2011-04-29 09:21:39',NULL,NULL,4,'Arrived to work at 8:00');
INSERT INTO "tasks" VALUES(295,NULL,NULL,'2011-05-02 08:46:19',NULL,NULL,4,'Arrive to work at 8:15');
INSERT INTO "tasks" VALUES(296,NULL,NULL,'2011-05-02 08:46:33',NULL,NULL,4,'Writing the final scenario to setup the account request and cancel');
INSERT INTO "tasks" VALUES(297,NULL,NULL,'2011-05-02 14:48:39',NULL,NULL,4,'Awaiting the latest upgrades by Bill...
Can''t make progress on integration testcases until Bill completes his API');
INSERT INTO "tasks" VALUES(298,NULL,NULL,'2011-05-03 10:33:56',NULL,NULL,4,'Arrive to work at 9:45');
INSERT INTO "tasks" VALUES(299,NULL,NULL,'2011-05-03 10:34:07',NULL,NULL,4,'Completing the last integration test');
INSERT INTO "tasks" VALUES(300,NULL,NULL,'2011-05-05 09:51:49',NULL,NULL,4,'Arrive to work at 9:20');
INSERT INTO "tasks" VALUES(301,NULL,NULL,'2011-05-05 09:52:21',NULL,NULL,4,'Creating test cases that check for the presence of a TestCall. Having to modify all of the existing testcases
so that they check for real work');
INSERT INTO "tasks" VALUES(302,NULL,NULL,'2011-05-10 09:19:07',NULL,NULL,4,'Arrived to work at 8:10');
INSERT INTO "tasks" VALUES(303,NULL,NULL,'2011-05-10 14:39:35',NULL,NULL,4,'Working on test cases for the Aria/Act Translation ');
INSERT INTO "tasks" VALUES(304,NULL,NULL,'2011-05-11 10:31:31',NULL,NULL,4,'Arrived to work at 10:00');
INSERT INTO "tasks" VALUES(305,NULL,NULL,'2011-05-11 13:15:14',NULL,NULL,4,'Going to talk to rick about testing');
INSERT INTO "tasks" VALUES(307,NULL,NULL,'2011-05-12 15:52:47',NULL,NULL,4,'Arrived to work at 8am');
INSERT INTO "tasks" VALUES(308,NULL,NULL,'2011-05-16 09:58:51',NULL,NULL,4,'Arrive to work at 9:20');
INSERT INTO "tasks" VALUES(309,NULL,NULL,'2011-05-16 09:58:59',NULL,NULL,4,'Working on translating the billing groups');
INSERT INTO "tasks" VALUES(310,NULL,NULL,'2011-05-18 10:21:04',NULL,NULL,4,'Arrive to work at 9:40');
INSERT INTO "tasks" VALUES(311,NULL,NULL,'2011-05-20 17:48:27',NULL,NULL,4,'Arrive to work at 8:00');
INSERT INTO "tasks" VALUES(312,NULL,NULL,'2011-05-20 17:48:55',NULL,NULL,4,'Talking to PBJ about stuff');
INSERT INTO "tasks" VALUES(313,NULL,'2011-05-21','2011-05-20 17:50:27','2011-05-20 17:50:26','2011-05-20 17:51:05',1,'Do something');
INSERT INTO "tasks" VALUES(314,NULL,NULL,'2011-05-23 07:52:50',NULL,NULL,4,'Arrive to work 3:52');
INSERT INTO "tasks" VALUES(315,NULL,NULL,'2011-05-23 07:52:56',NULL,NULL,4,'Working on translation objects');
INSERT INTO "tasks" VALUES(316,NULL,NULL,'2011-05-24 10:17:53',NULL,NULL,4,'Arrived to work at 7:15');
INSERT INTO "tasks" VALUES(317,NULL,NULL,'2011-05-27 07:26:08',NULL,NULL,4,'Arrived to work at 7:00');
INSERT INTO "tasks" VALUES(318,NULL,NULL,'2011-05-27 07:26:21',NULL,NULL,4,'Working on the add user from the tool aria_audit.pl');
INSERT INTO "tasks" VALUES(319,NULL,NULL,'2011-05-31 08:12:44',NULL,NULL,4,'Arrived to work at 7:55');
INSERT INTO "tasks" VALUES(320,NULL,NULL,'2011-05-31 08:14:10',NULL,NULL,4,'Working on command line tool for adding accounts');
INSERT INTO "tasks" VALUES(321,NULL,NULL,'2011-06-02 09:15:58',NULL,NULL,4,'Arrived to work at 7:30');
INSERT INTO "tasks" VALUES(322,NULL,'2011-06-02','2011-06-02 09:16:20','2011-06-02 00:00:00','2011-06-09 13:07:01',1,'Standardize java addons');
INSERT INTO "tasks" VALUES(323,NULL,NULL,'2011-06-06 09:08:52',NULL,NULL,4,'Arrived to work at 8:20');
INSERT INTO "tasks" VALUES(324,NULL,NULL,'2011-06-06 09:09:11',NULL,NULL,4,'Working on tasking for Aria. Trying to figure out how to best utilize Jim and Bill');
INSERT INTO "tasks" VALUES(325,NULL,NULL,'2011-06-06 19:35:07',NULL,NULL,4,'Completed tasking , sending it to Bill and James for feedback');
INSERT INTO "tasks" VALUES(326,NULL,NULL,'2011-06-07 10:58:18',NULL,NULL,4,'Arrived to work at 9:10am ( doctor''s appointment )
');
INSERT INTO "tasks" VALUES(327,NULL,NULL,'2011-06-07 11:41:33',NULL,NULL,4,'Dropped off pics for Seth to draw');
INSERT INTO "tasks" VALUES(328,NULL,NULL,'2011-06-08 08:51:22',NULL,NULL,4,'Arrived to work at 8:49');
INSERT INTO "tasks" VALUES(329,NULL,NULL,'2011-06-08 08:51:41',NULL,NULL,4,'Working on SHA1 and UNIQUEID field uploads');
INSERT INTO "tasks" VALUES(330,NULL,'2011-06-08','2011-06-08 14:49:26','2011-06-08 00:00:00',NULL,1,'Create interactive environment for adding / mod accounts');
INSERT INTO "tasks" VALUES(331,NULL,'2011-06-08','2011-06-08 14:50:33','2011-06-08 00:00:00','2011-06-09 13:06:52',1,'Create SHA1 upload example');
INSERT INTO "tasks" VALUES(332,NULL,'2011-06-13','2011-06-08 14:51:11','2011-06-10 00:00:00','2011-06-18 19:55:00',1,'Dump an account out to CSV');
INSERT INTO "tasks" VALUES(333,NULL,NULL,'2011-06-09 15:17:16',NULL,NULL,4,'Arrive to work at 8:30');
INSERT INTO "tasks" VALUES(334,NULL,NULL,'2011-06-13 09:27:58',NULL,NULL,4,'Arrive to work at 8:20');
INSERT INTO "tasks" VALUES(335,NULL,NULL,'2011-06-14 09:41:04',NULL,NULL,4,'Arrive to work at 9:18');
INSERT INTO "tasks" VALUES(336,NULL,NULL,'2011-06-14 09:41:24',NULL,NULL,4,'Deciding what to do with the aria queries. Need to play around with them ');
INSERT INTO "tasks" VALUES(337,NULL,NULL,'2011-06-18 19:54:29',NULL,NULL,4,'Working on Java XML parsing');
INSERT INTO "tasks" VALUES(338,NULL,NULL,'2011-06-20 07:46:07',NULL,NULL,4,'Arrive to work at 7:30');
INSERT INTO "tasks" VALUES(339,NULL,NULL,'2011-06-20 09:32:37',NULL,NULL,4,'Working on the interface to the aria auditing tool...problems exist with blank query criteria that get passed in ');
INSERT INTO "tasks" VALUES(340,NULL,NULL,'2011-06-21 07:49:21',NULL,NULL,4,'Arrived to work at 7:05');
INSERT INTO "tasks" VALUES(341,NULL,NULL,'2011-06-24 11:18:48',NULL,NULL,4,'Arrived to work at 10:00');
INSERT INTO "tasks" VALUES(342,NULL,NULL,'2011-06-24 11:19:15',NULL,NULL,4,'Working on update testcases in Aria from the command line');
INSERT INTO "tasks" VALUES(343,NULL,NULL,'2011-06-27 08:57:00',NULL,NULL,4,'Arrive to work at 8:00');
INSERT INTO "tasks" VALUES(346,NULL,NULL,'2011-06-27 09:38:06',NULL,NULL,4,'Hello');
INSERT INTO "tasks" VALUES(352,NULL,NULL,'2011-06-27 09:45:41',NULL,NULL,4,'Arrive to work at 8:30');
INSERT INTO "tasks" VALUES(353,NULL,'2011-06-27','2011-06-27 09:49:06','2011-06-27 00:00:00','2011-07-05 11:29:38',3,'Get updating working');
INSERT INTO "tasks" VALUES(354,NULL,NULL,'2011-07-05 11:29:09',NULL,NULL,4,'Arrive to work at 10:45');
INSERT INTO "tasks" VALUES(355,NULL,'2011-07-05','2011-07-05 11:30:06','2011-07-05 00:00:00','2011-07-19 09:20:38',3,'Create Sku Class');
INSERT INTO "tasks" VALUES(356,NULL,'2011-07-07','2011-07-05 11:30:35','2011-07-06 00:00:00','2011-08-05 11:32:45',3,'Package existing code for command line');
INSERT INTO "tasks" VALUES(357,NULL,'2011-07-05','2011-07-05 12:03:44','2011-07-05 00:00:00','2011-07-10 17:13:38',3,'Get dump working with new Object structure');
INSERT INTO "tasks" VALUES(358,NULL,NULL,'2011-07-05 12:04:51',NULL,NULL,4,'Working on refactoring code into new Object structure');
INSERT INTO "tasks" VALUES(359,NULL,NULL,'2011-07-10 14:34:10',NULL,NULL,4,'Finished class for querying ACt records');
INSERT INTO "tasks" VALUES(360,NULL,'2011-07-08','2011-07-10 17:14:36','2011-07-06 00:00:00','2011-08-05 11:32:57',3,'Determine system for updating a records with new Aria information');
INSERT INTO "tasks" VALUES(361,NULL,NULL,'2011-07-11 09:39:12',NULL,NULL,4,'Arrived to work at 8:45');
INSERT INTO "tasks" VALUES(362,NULL,NULL,'2011-07-13 14:29:11',NULL,NULL,4,'Arrive to work at 8:45');
INSERT INTO "tasks" VALUES(363,NULL,NULL,'2011-07-18 12:34:01',NULL,NULL,4,'Arrive to work at 8:10');
INSERT INTO "tasks" VALUES(364,NULL,NULL,'2011-07-19 09:05:54',NULL,NULL,4,'Arrive to work at 8:15');
INSERT INTO "tasks" VALUES(365,NULL,'2011-07-19','2011-07-19 09:20:15','2011-07-19 16:00:00','2011-08-05 11:33:01',3,'Connect to the static dev db for testing');
INSERT INTO "tasks" VALUES(366,NULL,NULL,'2011-07-20 08:30:51',NULL,NULL,4,'Arrived to work at 8:17');
INSERT INTO "tasks" VALUES(367,NULL,NULL,'2011-07-22 08:25:58',NULL,NULL,4,'Arrive to work at 8:10');
INSERT INTO "tasks" VALUES(368,NULL,NULL,'2011-07-22 08:29:28',NULL,NULL,4,'
Working on Random Copy failures 

Also creating a replay script to test additions in the presense of failures

Also adding the YAML reply features');
INSERT INTO "tasks" VALUES(369,NULL,NULL,'2011-07-26 09:53:25',NULL,NULL,4,'Arrive to work at 9:45');
INSERT INTO "tasks" VALUES(370,NULL,NULL,'2011-07-27 08:18:12',NULL,NULL,4,'Arrive to work at 8:00');
INSERT INTO "tasks" VALUES(371,NULL,NULL,'2011-07-28 08:29:56',NULL,NULL,4,'Arrived to work at 8:00');
INSERT INTO "tasks" VALUES(372,NULL,NULL,'2011-08-01 09:36:09',NULL,NULL,4,'Arrived to work at 9:15');
INSERT INTO "tasks" VALUES(373,NULL,NULL,'2011-08-01 09:36:40',NULL,NULL,4,'Working on conversion of Act to Aria + Billing');
INSERT INTO "tasks" VALUES(374,NULL,NULL,'2011-08-02 09:50:15',NULL,NULL,4,'Arrived to work at 9:37');
INSERT INTO "tasks" VALUES(375,NULL,NULL,'2011-08-05 11:32:06',NULL,NULL,4,'Arrive to work at 8:35');
INSERT INTO "tasks" VALUES(376,NULL,NULL,'2011-08-06 11:38:17',NULL,NULL,4,'Arrived to Lestats at 11:00');
INSERT INTO "tasks" VALUES(377,NULL,NULL,'2011-08-06 11:38:27',NULL,NULL,4,'Working on code testing');
INSERT INTO "tasks" VALUES(378,NULL,NULL,'2011-08-06 13:21:56',NULL,NULL,4,'Completed @Crap');
INSERT INTO "tasks" VALUES(379,NULL,NULL,'2011-08-06 13:22:01',NULL,NULL,4,'Completed Gira Tasking');
INSERT INTO "tasks" VALUES(380,NULL,NULL,'2011-08-06 13:24:04',NULL,NULL,4,'Discovered that we might just need one cron job');
INSERT INTO "tasks" VALUES(382,NULL,'2011-08-05','2011-08-06 13:24:48','2011-08-05 00:00:00','2011-09-07 08:43:45',3,'Completed Pre-Prod Documentation');
INSERT INTO "tasks" VALUES(383,NULL,NULL,'2011-08-06 13:25:35',NULL,NULL,4,'Got my R documentation text file completed for getting started with R');
INSERT INTO "tasks" VALUES(384,NULL,NULL,'2011-08-08 09:58:21',NULL,NULL,4,'Arrived to work at 8:40');
INSERT INTO "tasks" VALUES(385,NULL,NULL,'2011-08-08 10:11:14',NULL,NULL,4,'Submitting ticket to get sudo privleges for aria_audit.pl
');
INSERT INTO "tasks" VALUES(386,NULL,'2011-08-09','2011-08-08 11:53:32','2011-08-08 15:00:00','2011-08-08 16:15:36',3,'Merge in Jim''s code');
INSERT INTO "tasks" VALUES(387,NULL,NULL,'2011-08-09 10:26:16',NULL,NULL,4,'Arrive to work at 8:40');
INSERT INTO "tasks" VALUES(388,NULL,'2011-08-10','2011-08-09 10:26:53','2011-08-09 14:00:00','2011-08-09 12:35:21',3,'Create Configuration File for aria_audit.pl');
INSERT INTO "tasks" VALUES(389,NULL,'2011-08-10','2011-08-09 10:27:21','2011-08-09 18:00:00','2011-08-09 17:56:45',3,'Test update/add and delete cronjobs');
INSERT INTO "tasks" VALUES(390,NULL,NULL,'2011-08-09 11:01:56',NULL,NULL,4,'Working on fixing configuration file for aria_audit.pl
I need to get Defaults.pm to use the Configuration object
');
INSERT INTO "tasks" VALUES(391,NULL,NULL,'2011-08-09 12:11:08',NULL,NULL,4,'Walked up stairs twice');
INSERT INTO "tasks" VALUES(393,NULL,NULL,'2011-08-09 12:21:26',NULL,NULL,4,'Vertical situps');
INSERT INTO "tasks" VALUES(394,NULL,NULL,'2011-08-09 12:21:46',NULL,NULL,4,'Completed testing of aria_audit.pl using new Config');
INSERT INTO "tasks" VALUES(396,NULL,NULL,'2011-08-09 18:01:27',NULL,NULL,4,'Completed Cron for update and deleted');
INSERT INTO "tasks" VALUES(398,NULL,'2011-08-12','2011-08-09 18:02:38','2011-08-12 12:00:00','2011-09-07 08:43:49',3,'Package up new release of Aria and Lib');
INSERT INTO "tasks" VALUES(399,NULL,NULL,'2011-08-10 09:25:43',NULL,NULL,4,'Arrive to work at 9:00');
INSERT INTO "tasks" VALUES(400,NULL,'2011-08-10','2011-08-10 09:31:43','2011-08-10 12:00:00','2011-08-11 10:23:39',3,'Create YAML log of failed accounts');
INSERT INTO "tasks" VALUES(401,NULL,'2011-08-10','2011-08-10 09:49:31','2011-08-10 16:00:00','2011-08-11 10:23:42',3,'Create config file option for replay logs');
INSERT INTO "tasks" VALUES(402,NULL,NULL,'2011-08-10 11:18:50',NULL,NULL,4,'Working on adding crons to package');
INSERT INTO "tasks" VALUES(403,NULL,NULL,'2011-08-10 13:12:26',NULL,NULL,4,'Fixing code to remove master_plan reference number');
INSERT INTO "tasks" VALUES(404,NULL,NULL,'2011-08-10 15:25:21',NULL,NULL,4,'Arrived at Lestat''s . Working on the Cron testing plus YAML log');
INSERT INTO "tasks" VALUES(405,NULL,NULL,'2011-08-11 08:51:47',NULL,NULL,4,'Arrive to work at 8:44');
INSERT INTO "tasks" VALUES(408,NULL,NULL,'2011-08-12 09:51:53',NULL,NULL,4,'Arrive to work at 9:15');
INSERT INTO "tasks" VALUES(409,NULL,NULL,'2011-08-12 11:39:30',NULL,NULL,4,'Writing scenarios for QA testing and the remaining development');
INSERT INTO "tasks" VALUES(411,NULL,NULL,'2011-08-15 15:23:34',NULL,NULL,4,'Arrived to work at 14:00');
INSERT INTO "tasks" VALUES(412,NULL,NULL,'2011-08-16 07:45:57',NULL,NULL,4,'Arrived to work at 7:40');
INSERT INTO "tasks" VALUES(413,NULL,NULL,'2011-08-17 07:59:14',NULL,NULL,4,'Arrived to work at 7:45');
INSERT INTO "tasks" VALUES(414,NULL,NULL,'2011-08-18 08:48:27',NULL,NULL,4,'Arrive to work at 8:35');
INSERT INTO "tasks" VALUES(415,NULL,NULL,'2011-08-18 09:30:15',NULL,NULL,4,'Working on log for scenarios to check values are ok');
INSERT INTO "tasks" VALUES(416,NULL,NULL,'2011-08-23 07:51:10',NULL,NULL,4,'Arrived to work at 6:50');
INSERT INTO "tasks" VALUES(417,NULL,NULL,'2011-08-24 10:48:04',NULL,NULL,4,'Arrive to work at 9:30');
INSERT INTO "tasks" VALUES(418,NULL,NULL,'2011-08-24 13:53:14',NULL,NULL,4,'Dealt with move to the 5th floor');
INSERT INTO "tasks" VALUES(419,NULL,NULL,'2011-08-24 17:57:11',NULL,NULL,4,'Trying to upload change to Git');
INSERT INTO "tasks" VALUES(420,NULL,NULL,'2011-08-25 08:40:23',NULL,NULL,4,'Arrived to work at 8:10');
INSERT INTO "tasks" VALUES(421,NULL,NULL,'2011-08-26 08:43:15',NULL,NULL,4,'Arrive to work at 8:00');
INSERT INTO "tasks" VALUES(422,NULL,NULL,'2011-08-26 13:35:02',NULL,NULL,4,'Must rent a truck for Norcal move');
INSERT INTO "tasks" VALUES(423,NULL,NULL,'2011-08-29 08:19:31',NULL,NULL,4,'Arrived to work at 8:00');
INSERT INTO "tasks" VALUES(424,NULL,NULL,'2011-08-30 08:23:55',NULL,NULL,4,'Arrived to work at 8:10');
INSERT INTO "tasks" VALUES(425,NULL,NULL,'2011-08-31 08:43:26',NULL,NULL,4,'Arrive to work at 8:30');
INSERT INTO "tasks" VALUES(426,NULL,NULL,'2011-09-01 08:22:05',NULL,NULL,4,'Arrive to work at 7:50');
INSERT INTO "tasks" VALUES(427,NULL,NULL,'2011-09-06 08:16:55',NULL,NULL,4,'Started work at 7:30');
INSERT INTO "tasks" VALUES(428,NULL,NULL,'2011-09-07 08:40:55',NULL,NULL,4,'Arrived to work at 7:20');
INSERT INTO "tasks" VALUES(429,NULL,NULL,'2011-09-08 07:50:02',NULL,NULL,4,'Arrived to work at 7:22');
INSERT INTO "tasks" VALUES(430,NULL,'2011-09-12','2011-09-12 07:44:21','2011-09-12 08:30:00','2011-09-12 08:37:47',3,'Fill out hours');
INSERT INTO "tasks" VALUES(431,NULL,'2011-09-12','2011-09-12 07:44:44','2011-09-12 11:00:00','2011-09-19 08:27:37',3,'Purchase ticket to east coast');
INSERT INTO "tasks" VALUES(432,NULL,NULL,'2011-09-12 08:08:24',NULL,NULL,4,'Arrived to work at 7:25');
INSERT INTO "tasks" VALUES(434,NULL,NULL,'2011-09-12 08:17:39',NULL,NULL,4,'Working on timesheets
');
INSERT INTO "tasks" VALUES(435,NULL,'2011-09-13','2011-09-12 11:43:06','2011-09-12 14:00:00','2011-09-19 08:27:23',3,'Complete new hire forms');
INSERT INTO "tasks" VALUES(436,NULL,NULL,'2011-09-12 11:44:26',NULL,NULL,4,'Finishing up work debugging Address mapping examples');
INSERT INTO "tasks" VALUES(437,NULL,NULL,'2011-09-13 08:30:39',NULL,NULL,4,'Arrived to work at 8:15');
INSERT INTO "tasks" VALUES(438,NULL,NULL,'2011-09-15 09:17:02',NULL,NULL,4,'Arrived to work at 9:00');
INSERT INTO "tasks" VALUES(439,NULL,NULL,'2011-09-16 17:59:39',NULL,NULL,4,'Arrived to work at 7:50');
INSERT INTO "tasks" VALUES(440,NULL,NULL,'2011-09-16 17:59:58',NULL,NULL,4,'Error exists with type of account/ translation to Aria');
INSERT INTO "tasks" VALUES(441,NULL,NULL,'2011-09-19 08:24:43',NULL,NULL,4,'Arrived to work at 7:49');
INSERT INTO "tasks" VALUES(442,NULL,'2011-09-20','2011-09-19 08:31:03','1100-01-01 00:00:00','2011-09-19 11:01:52',3,'Release code as package');
INSERT INTO "tasks" VALUES(443,NULL,NULL,'2011-09-19 11:01:32',NULL,NULL,4,'Completed package, dropped and released');
INSERT INTO "tasks" VALUES(444,NULL,NULL,'2011-09-20 11:45:13',NULL,NULL,4,'Arrived to work at 8:40');
INSERT INTO "tasks" VALUES(445,NULL,'2011-09-20','2011-09-20 11:45:38','2011-09-20 13:00:00','2011-11-03 13:07:00',3,'Create Address modification scenario');
INSERT INTO "tasks" VALUES(446,NULL,NULL,'2011-09-21 09:04:52',NULL,NULL,4,'Arrived to work at 7:50');
INSERT INTO "tasks" VALUES(447,NULL,NULL,'2011-09-23 07:50:52',NULL,NULL,4,'Arrived to work at 7:34');
INSERT INTO "tasks" VALUES(448,NULL,NULL,'2011-09-23 07:52:51',NULL,NULL,4,'Fixing the query with my own object');
INSERT INTO "tasks" VALUES(450,NULL,NULL,'2011-10-04 08:22:01',NULL,NULL,4,'Arrived to work at 7:43');
INSERT INTO "tasks" VALUES(451,NULL,NULL,'2011-10-09 11:06:56',NULL,NULL,4,'Woke up at 8:00 am');
INSERT INTO "tasks" VALUES(452,NULL,NULL,'2011-10-09 11:07:03',NULL,NULL,4,'Working on Homework problems');
INSERT INTO "tasks" VALUES(453,NULL,NULL,'2011-10-13 10:05:09',NULL,NULL,4,'Arrived to work at 8:38');
INSERT INTO "tasks" VALUES(454,NULL,NULL,'2011-10-14 08:09:12',NULL,NULL,4,'Arrived to work at 7:50');
INSERT INTO "tasks" VALUES(455,NULL,NULL,'2011-10-17 07:56:06',NULL,NULL,4,'Arrived to work at 7:10');
INSERT INTO "tasks" VALUES(456,NULL,NULL,'2011-10-17 07:56:28',NULL,NULL,4,'Need to work on Scenarios that test the rollover system');
INSERT INTO "tasks" VALUES(457,NULL,NULL,'2011-10-18 09:52:29',NULL,NULL,4,'Arrived to work at 9:40');
INSERT INTO "tasks" VALUES(458,NULL,NULL,'2011-10-19 09:10:53',NULL,NULL,4,'Arrived to work at 9:05');
INSERT INTO "tasks" VALUES(459,NULL,NULL,'2011-10-20 09:24:12',NULL,NULL,4,'Arrived to work at 8:15');
INSERT INTO "tasks" VALUES(460,NULL,NULL,'2011-10-24 09:25:13',NULL,NULL,4,'Arrived to work at 9:10');
INSERT INTO "tasks" VALUES(461,NULL,NULL,'2011-10-25 07:59:29',NULL,NULL,4,'Arrived to work at 7:25');
INSERT INTO "tasks" VALUES(462,NULL,NULL,'2011-10-25 07:59:44',NULL,NULL,4,'Working on the Plan tool, to modify billing dates');
INSERT INTO "tasks" VALUES(463,NULL,NULL,'2011-10-25 14:48:13',NULL,NULL,4,'Blocker with getting permissions to add plans to Aria');
INSERT INTO "tasks" VALUES(464,NULL,NULL,'2011-10-26 08:58:10',NULL,NULL,4,'Arrived to work at 8');
INSERT INTO "tasks" VALUES(465,NULL,NULL,'2011-10-26 08:58:45',NULL,NULL,4,'Discovered that work / life annoyances prevent you from completing the things that you wish to complete');
INSERT INTO "tasks" VALUES(466,NULL,NULL,'2011-11-03 13:06:43',NULL,NULL,4,'Arrived to work at 8:50');
INSERT INTO "tasks" VALUES(467,NULL,NULL,'2011-11-07 01:00:40',NULL,NULL,4,'Working on the Moose fix for the SkuPlan mapping');
INSERT INTO "tasks" VALUES(468,NULL,NULL,'2011-11-12 09:23:14',NULL,NULL,4,'Working on the get_acct_no from user_id');
INSERT INTO "tasks" VALUES(469,NULL,NULL,'2011-11-14 07:27:42',NULL,NULL,4,'Arrived to work at 7:20');
INSERT INTO "tasks" VALUES(470,NULL,NULL,'2011-11-14 07:34:05',NULL,'2011-12-13 11:26:09',3,'Create update password');
INSERT INTO "tasks" VALUES(471,NULL,NULL,'2011-11-17 14:03:58',NULL,NULL,4,'Arrived to work at noon');
INSERT INTO "tasks" VALUES(472,NULL,NULL,'2011-11-17 14:04:12',NULL,NULL,4,'Working on getting the correct adapter working');
INSERT INTO "tasks" VALUES(473,NULL,NULL,'2011-11-20 06:51:01',NULL,NULL,4,'Working on plans for Aria');
INSERT INTO "tasks" VALUES(474,NULL,NULL,'2011-11-20 07:21:35',NULL,NULL,4,'Found notes on ruby rake tasks

>> require ''rubygems''
>> require ''hirb''
>> Hirb.enable
');
INSERT INTO "tasks" VALUES(475,NULL,NULL,'2011-11-20 07:59:22',NULL,NULL,4,'Worked on ruby and rails, figured out how to make diary work better');
INSERT INTO "tasks" VALUES(476,NULL,NULL,'2011-11-28 09:43:27',NULL,NULL,4,'Arrived to work at 9:15');
INSERT INTO "tasks" VALUES(477,NULL,NULL,'2011-11-29 10:12:50',NULL,NULL,4,'Arrived to work at 9:40');
INSERT INTO "tasks" VALUES(478,NULL,NULL,'2011-12-06 09:49:45',NULL,NULL,4,'Arrived to work at 9:25');
INSERT INTO "tasks" VALUES(479,NULL,NULL,'2011-12-13 09:31:13',NULL,NULL,4,'Arrived to work at 9:25');
INSERT INTO "tasks" VALUES(480,NULL,'2011-12-14','2011-12-13 10:00:16','2011-12-13 13:00:00','2011-12-13 11:00:00',3,'https://jira.programx60.com/browse/CONCA-194');
INSERT INTO "tasks" VALUES(481,NULL,NULL,'2011-12-13 10:01:34',NULL,NULL,4,'Working on create_account');
INSERT INTO "tasks" VALUES(482,NULL,NULL,'2011-12-14 10:07:29',NULL,NULL,4,'Arrived to work at 9:20');
INSERT INTO "tasks" VALUES(483,NULL,'2011-12-16','2011-12-14 10:08:08','2011-12-15 00:00:00','2012-01-03 13:57:39',3,'Create deprovisining library');
INSERT INTO "tasks" VALUES(484,NULL,NULL,'2011-12-15 10:24:51',NULL,NULL,4,'Started work at 9:25');
INSERT INTO "tasks" VALUES(486,NULL,NULL,'2011-12-17 14:00:15',NULL,NULL,4,'Working on my personal time issues');
INSERT INTO "tasks" VALUES(487,NULL,NULL,'2011-12-18 01:52:25',NULL,NULL,4,'Working on Web applications');
INSERT INTO "tasks" VALUES(488,NULL,NULL,'2011-12-18 14:17:09',NULL,NULL,4,'Starting work at 14:17');
INSERT INTO "tasks" VALUES(489,NULL,NULL,'2011-12-19 08:49:20',NULL,NULL,4,'Starting work at 8:40');
INSERT INTO "tasks" VALUES(490,NULL,NULL,'2011-12-19 10:14:08',NULL,NULL,4,'Working on Bill''s Api');
INSERT INTO "tasks" VALUES(491,NULL,NULL,'2011-12-19 16:46:14',NULL,NULL,4,'Make sure that you add the start dates');
INSERT INTO "tasks" VALUES(492,NULL,NULL,'2011-12-27 08:18:40',NULL,NULL,4,'Arrived to work at 8:00');
INSERT INTO "tasks" VALUES(493,NULL,NULL,'2011-12-27 12:32:08',NULL,NULL,4,'Building package for Moose Params Validator');
INSERT INTO "tasks" VALUES(494,NULL,NULL,'2011-12-28 08:05:35',NULL,NULL,4,'Arrived to work at 7:40');
INSERT INTO "tasks" VALUES(495,NULL,NULL,'2012-01-03 13:51:03',NULL,NULL,4,'Arrived to work at 12:30');
INSERT INTO "tasks" VALUES(496,NULL,NULL,'2012-01-04 12:43:59',NULL,NULL,4,'Arrived to work at 11:30');
INSERT INTO "tasks" VALUES(497,NULL,NULL,'2012-01-04 12:44:33',NULL,NULL,4,'Making a goal of trying to record the things
that I do this year and be more effective with my working schedule. I am also going to make 
more time for relaxation as that adds to my effectiveness');
INSERT INTO "tasks" VALUES(498,NULL,NULL,'2012-01-04 14:43:51',NULL,NULL,4,'Examining how to test web pages');
INSERT INTO "tasks" VALUES(499,NULL,NULL,'2012-01-04 14:44:08',NULL,NULL,4,'Also realizing that sitting with proper posture helps correct other bad habbits
');
INSERT INTO "tasks" VALUES(500,NULL,NULL,'2012-01-04 14:44:17',NULL,NULL,4,'Spend more time using a belt while at work');
INSERT INTO "tasks" VALUES(501,NULL,NULL,'2012-01-04 14:44:31',NULL,NULL,4,'Set aside a goal for the amount of time between your meals');
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('categories',4);
INSERT INTO "sqlite_sequence" VALUES('tags',2);
INSERT INTO "sqlite_sequence" VALUES('tags_tasks',1);
INSERT INTO "sqlite_sequence" VALUES('parent_relationships',7);
INSERT INTO "sqlite_sequence" VALUES('tasks',501);
COMMIT;
