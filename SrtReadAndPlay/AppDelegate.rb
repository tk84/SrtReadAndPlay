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
  attr_accessor :timeline
  attr_accessor :timelinePlaceholder
  attr_accessor :timelinePath
  attr_accessor :media
  attr_accessor :mediaPath

  def applicationDidFinishLaunching(a_notification)
    # Insert code here to initialize your application
  end

  def windowWillClose aNotification

  end

  def loadMedia sender
    panel = NSOpenPanel.openPanel
    panel.setAllowedFileTypes ['mp4', 'm4v']

    if NSOKButton == panel.runModal
      media = MediaController.alloc;

      if media.model = MediaModel.makeModel(panel.URL)
        @mediaPath.setURL panel.URL
        @media.stop if @media
        @media = media.initWithNibName 'Media', bundle:nil
        @media.view             # awakeFromNibに通知を送る的な
        @timeline.selectCallback = @media.registCallback if @timeline
      end
    end
  end

  def loadSrt sender
    panel = NSOpenPanel.openPanel
    panel.setAllowedFileTypes ['srt']

    if NSOKButton == panel.runModal
      timeline = TimelineController.alloc;

      if timeline.model = TimelineModel.makeModel(panel.URL)
        @timelinePath.setURL panel.URL
        @timeline.view.removeFromSuperview if @timeline
        @timeline = timeline.initWithNibName('Timeline', bundle:nil)
        @timeline.view.setFrame @timelinePlaceholder.bounds
        @timeline.view.setAutoresizingMask NSViewWidthSizable | NSViewHeightSizable
        @timelinePlaceholder.addSubview @timeline.view
        @timeline.selectCallback = @media.registCallback if @media
     end
    end
  end
end

