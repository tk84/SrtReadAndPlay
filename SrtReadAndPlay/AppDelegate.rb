# -*- coding: utf-8 -*-
#
#  AppDelegate.rb
#  SrtReadAndPlay
#
#  Created by Hiroyuki Takahashi on 11/10/21.
#  Copyright 2011年 __MyCompanyName__. All rights reserved.
#

class AppDelegate
  attr_accessor :window
  attr_accessor :mainView
  attr_accessor :button
  def applicationDidFinishLaunching(a_notification)
    # Insert code here to initialize your application

  end

  def awakeFromNib

  end

  def loadMedia sender

  end

  def loadSrt sender
    panel = NSOpenPanel.openPanel
    panel.setAllowedFileTypes ['srt']

    if NSOKButton == panel.runModal
      timeline = TimelineController.alloc;

      if timeline.model = TimelineModel.makeModel(panel.URL)
        timeline.initWithNibName 'Timeline', bundle:nil
        timeline.view.setFrame @mainView.view.bounds
        timeline.view.setAutoresizingMask NSViewWidthSizable | NSViewHeightSizable
        @mainView.view.addSubview timeline.view
      end
    end
  end

  def takeAction sender
    controller = NSViewController.alloc.initWithNibName 'Timeline', bundle:nil
    controller.view.setFrame @mainView.view.bounds
    controller.view.setAutoresizingMask NSViewWidthSizable | NSViewHeightSizable

    #	[[propertyView view] setFrame: [targetView bounds]];
    #    [[propertyView view] setAutoresizingMask:( NSViewWidthSizable | NSViewHeightSizable )];

    #p controller.view
        @mainView.view.addSubview controller.view
  end
end

