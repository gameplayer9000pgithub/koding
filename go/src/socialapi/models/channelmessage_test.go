package models

import (
	"socialapi/workers/common/runner"
	"testing"
	"time"

	. "github.com/smartystreets/goconvey/convey"
)

func createMessageWithTest() *ChannelMessage {
	cm := NewChannelMessage()

	// init account
	account, err := createAccount()
	So(err, ShouldBeNil)
	So(account, ShouldNotBeNil)
	So(account.Id, ShouldNotEqual, 0)
	// init channel
	channel, err := createChannel(account.Id)
	So(err, ShouldBeNil)
	So(channel, ShouldNotBeNil)

	// set account id
	cm.AccountId = account.Id
	// set channel id
	cm.InitialChannelId = channel.Id
	// set body
	cm.Body = "5five"
	return cm
}

func TestChannelMessageCreate(t *testing.T) {
	r := runner.New("test")
	if err := r.Init(); err != nil {
		t.Fatalf("couldnt start bongo %s", err.Error())
	}
	defer r.Close()

	Convey("while creating channel message", t, func() {
		Convey("0 length body could not be inserted ", func() {
			cm := NewChannelMessage()
			So(cm.Create(), ShouldNotBeNil)
			So(cm.Create().Error(), ShouldContainSubstring, "message body length should be greater than")
		})

		Convey("type constant should be given", func() {
			cm := createMessageWithTest()
			cm.TypeConstant = ""
			So(cm.Create(), ShouldNotBeNil)
			So(cm.Create().Error(), ShouldContainSubstring, "pq: invalid input value for enum channel_message_type_constant_enum: \"\"")
		})

		Convey("type constant can be post", func() {
			cm := createMessageWithTest()
			// remove type Constant
			cm.TypeConstant = ChannelMessage_TYPE_POST

			So(cm.Create(), ShouldBeNil)

			icm := NewChannelMessage()
			err := icm.ById(cm.Id)
			So(err, ShouldBeNil)
			So(icm.Id, ShouldEqual, cm.Id)
			So(icm.TypeConstant, ShouldEqual, ChannelMessage_TYPE_POST)
		})

		Convey("type constant can be reply", func() {
			cm := createMessageWithTest()
			// remove type Constant
			cm.TypeConstant = ChannelMessage_TYPE_REPLY

			So(cm.Create(), ShouldBeNil)

			icm := NewChannelMessage()
			err := icm.ById(cm.Id)
			So(err, ShouldBeNil)
			So(icm.Id, ShouldEqual, cm.Id)
			So(icm.TypeConstant, ShouldEqual, ChannelMessage_TYPE_REPLY)
		})
		Convey("type constant can be join", func() {
			cm := createMessageWithTest()
			// remove type Constant
			cm.TypeConstant = ChannelMessage_TYPE_JOIN

			So(cm.Create(), ShouldBeNil)

			icm := NewChannelMessage()
			err := icm.ById(cm.Id)
			So(err, ShouldBeNil)
			So(icm.Id, ShouldEqual, cm.Id)
			So(icm.TypeConstant, ShouldEqual, ChannelMessage_TYPE_JOIN)
		})

		Convey("type constant can be leave", func() {
			cm := createMessageWithTest()
			// remove type Constant
			cm.TypeConstant = ChannelMessage_TYPE_LEAVE

			So(cm.Create(), ShouldBeNil)

			icm := NewChannelMessage()
			err := icm.ById(cm.Id)
			So(err, ShouldBeNil)
			So(icm.Id, ShouldEqual, cm.Id)
			So(icm.TypeConstant, ShouldEqual, ChannelMessage_TYPE_LEAVE)
		})

		Convey("type constant can be chat", func() {
			cm := createMessageWithTest()
			// remove type Constant
			cm.TypeConstant = ChannelMessage_TYPE_CHAT

			So(cm.Create(), ShouldBeNil)

			icm := NewChannelMessage()
			err := icm.ById(cm.Id)
			So(err, ShouldBeNil)
			So(icm.Id, ShouldEqual, cm.Id)
			So(icm.TypeConstant, ShouldEqual, ChannelMessage_TYPE_CHAT)
		})

		Convey("type constant can be privatemessage", func() {
			cm := createMessageWithTest()
			// remove type Constant
			cm.TypeConstant = ChannelMessage_TYPE_PRIVATE_MESSAGE

			So(cm.Create(), ShouldBeNil)

			icm := NewChannelMessage()
			err := icm.ById(cm.Id)
			So(err, ShouldBeNil)
			So(icm.Id, ShouldEqual, cm.Id)
			So(icm.TypeConstant, ShouldEqual, ChannelMessage_TYPE_PRIVATE_MESSAGE)
		})

		Convey("5 length body could be inserted ", func() {
			cm := createMessageWithTest()
			// set body
			cm.Body = "5five"

			// try to create the message
			So(cm.Create(), ShouldBeNil)
		})

		Convey("message should have slug after inserting ", func() {
			// create message
			cm := createMessageWithTest()
			// be sure that our message doesnt have slug
			So(cm.Id, ShouldBeZeroValue)
			So(cm.Slug, ShouldBeZeroValue)
			// try to create the message
			So(cm.Create(), ShouldBeNil)
			So(cm.Id, ShouldNotEqual, 0)

			// fetch created message
			icm := NewChannelMessage()
			err := icm.ById(cm.Id)
			So(err, ShouldBeNil)
			So(icm.Id, ShouldNotEqual, 0)
			So(icm.Slug, ShouldNotEqual, "")
		})
	})
}

func TestChannelMessageUpdate(t *testing.T) {
	r := runner.New("test")
	if err := r.Init(); err != nil {
		t.Fatalf("couldnt start bongo %s", err.Error())
	}
	defer r.Close()

	Convey("while updating channel message", t, func() {
		Convey("0 length body could not be updated ", func() {
			cm := createMessageWithTest()
			So(cm.Create(), ShouldBeNil)

			// clear message body
			cm.Body = ""
			So(cm.Update(), ShouldNotBeEmpty)
			So(cm.Update().Error(), ShouldContainSubstring, "message body length should be greater than")
		})

		Convey("valid length body can  be updated ", func() {
			// create message in the db
			cm := createMessageWithTest()
			So(cm.Create(), ShouldBeNil)

			// update the db
			body := "my updated text"

			// clear message body
			cm.Body = body
			So(cm.Update(), ShouldBeEmpty)

			// fetch createed/updated message from db
			icm := NewChannelMessage()
			err := icm.ById(cm.Id)
			So(err, ShouldBeNil)
			So(icm.Body, ShouldEqual, body)
		})

		Convey("valid length body can  be updated ", func() {
			// create message in the db
			cm := createMessageWithTest()
			So(cm.Create(), ShouldBeNil)

			// update the db
			body := "my updated text"

			// clear message body
			cm.Body = body
			So(cm.Update(), ShouldBeEmpty)

			// fetch createed/updated message from db
			icm := NewChannelMessage()
			err := icm.ById(cm.Id)
			So(err, ShouldBeNil)
			So(icm.Body, ShouldEqual, body)
		})

		Convey("meta bits can not be updated", nil)

		Convey("token can not  be updated ", func() {
			// create message in the db
			cm := createMessageWithTest()
			So(cm.Create(), ShouldBeNil)

			// update the db
			token := NewToken(time.Now()).String()

			// clear message body
			cm.Token = token

			err := cm.Update()
			So(err, ShouldBeNil)

			// fetch createed/updated message from db
			icm := NewChannelMessage()
			err = icm.ById(cm.Id)
			So(err, ShouldBeNil)
			So(icm.Token, ShouldNotEqual, token)
		})
		// write functions for other fields
		// slug
		// typeConstant
		// AccountId
		// InitialChannelId
		// CreatedAt
	})
}

func TestChannelMessageGetTableName(t *testing.T) {
	Convey("while testing TableName()", t, func() {
		So(NewChannelMessage().TableName(), ShouldEqual, ChannelMessageTableName)
	})
}
