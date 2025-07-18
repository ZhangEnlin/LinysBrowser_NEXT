import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysSymbol from '../../components/texts/linysSymbol';
import linysText from '../../components/texts/linysText';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default, animation_popup_duration, click_effect_default } from '../../hosts/bunch_of_defaults';
import { copy } from '../../utils/clipboard_tools';
import { preview_image } from '../../utils/preview_tools';
import { add_units_to_size, document_save_from_uri as document_save_from_uri, get_file_size_Sync, get_file_suffix } from '../../utils/storage_tools';
import { extract_links_from_text } from '../../utils/url_tools';
import { LengthMetrics } from '@kit.ArkUI';

@Component
struct meowScratchingBoard {
  // Links
  @StorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  @StorageLink('drop_result_strings') @Watch('on_data_change') data_list: string[] = [];
  // UI
  @Prop show_feed_prompt: boolean = true;
  @State area_height: number = 200;
  @StorageProp('screen_height') screen_height: number = 0;
  @State delete_confirm: number = 0;
  @State only_links: boolean = false;
  // Processed data
  @State extracted_data: string[] = [];
  @State extracted_type: string[] = [];
  // Else
  scroll_controller: Scroller = new Scroller();
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 10 }) {
      linysTextTitle({
        text: this.show_feed_prompt ? $r('app.string.Index_drop_please') : $r('app.string.Index_drop_ok')
      })
        .width(this.show_feed_prompt ? undefined : "100%")
        .animation(animation_default())

      Scroll(this.scroll_controller) {
        Column({ space: 10 }) {
          ForEach(this.extracted_data, (item: string, index: number) => {
            raw_data_display({
              text: item,
              type: this.extracted_type[index],
              index: index,
              showing_scratching_board: this.showing_scratching_board,
            })// Filter only links
              .visibility(this.only_links && this.extracted_type[index] != 'url' ? Visibility.None : Visibility.Visible)
              .animation(animation_default())
          })
        }
        .alignItems(HorizontalAlign.Start)
        .onAreaChange((_old, n) => {
          this.area_height = n.height as number;
        })
        .width("100%")
        .animation(animation_default())
      } // Text and links data display
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
      .layoutWeight(1)
      .visibility(this.show_feed_prompt ? Visibility.None : Visibility.Visible)
      .width("100%")
      .animation(animation_default())

      Row({ space: 10 }) {
        linysTimeoutButton({
          text: "  󰀁  ",
          onExecution: () => {
            this.clear_data();
          }
        })

        linysCapsuleButton({
          text: this.only_links ? "  󰄏  " : "  󰃁  "
        })
          .animation(animation_default())
          .onClick(() => {
            this.only_links = !this.only_links;
          })
      }
      .justifyContent(FlexAlign.End)
      .width("100%")
      .visibility(this.data_list.length > 0 ? Visibility.Visible : Visibility.None)
      .animation(animation_default())

    }
    .justifyContent(FlexAlign.Center)
    .padding({ left: 15, right: 15 })
    .width("100%")
    .height((this.show_feed_prompt ? 0.3 * this.screen_height :
    Math.min(this.area_height + 43, 0.6 * this.screen_height)) + 40)
    .animation(animation_default())
    .onAppear(() => {
      setInterval(() => {
        if (this.delete_confirm > 0) {
          this.delete_confirm -= 1;
        }
        // Reset delete confirm
      }, 10)
    })
  }

  /**
   * Called when new data comes
   *
   * If data is cleared then show feed prompt next time
   * */
  on_data_change() {
    if (this.data_list.length > 0) {
      this.show_feed_prompt = false;
    } else {
      this.show_feed_prompt = true;
    }

    // Analyzes the data and extract web links
    let extracted_result = extract_links_from_text(this.data_list);
    this.extracted_data = extracted_result[0];
    this.extracted_type = extracted_result[1];

    // console.log(this.extracted_data.join("\n"))
    this.scroll_controller.scrollEdge(Edge.Top);
  }

  clear_data() {
    // Clear all scratching board data
    this.data_list = [];
    this.showing_scratching_board = false;
  }
}

export default meowScratchingBoard;

@Component
struct raw_data_display {
  @Link showing_scratching_board: boolean;
  @State text: string = "meow";
  @State type: string = "text";
  @State image_size: string = "233x233";
  @State index: number = 0;
  @State offset_y: number = 50;
  @State this_visibility: Visibility = Visibility.Hidden;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Environment
  @StorageLink('universal_new_tab_gateway') new_tab_gateway: string = "";
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageProp('screen_width') screen_width: number = 0;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Status
  @State copied: number = 0;
  @State image_height: number = 0;
  @State image_width: number = 0;

  build() {
    Row({ space: 15 }) {
      if (this.type == 'image') {
        RelativeContainer() {
          Image(this.text)
            .width(Math.min(300, this.screen_width - 100))
            .borderRadius(10)
            .onComplete((event) => {
              let imageWidth = event?.width;
              let imageHeight = event?.height;
              this.image_size = imageWidth + 'x' + imageHeight
              // console.info('imageWidth:'+imageWidth,'imageHeight:'+imageHeight);
            })
            .id('image')
            .onAreaChange((_o, n) => {
              this.image_height = n.height as number;
              this.image_width = n.width as number;
            })

          Scroll() {
            Flex({
              direction: !this.tablet_mode ? FlexDirection.Row : FlexDirection.Column,
              space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) }
            }) {
              linysText({ text: this.image_size })// Size
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .padding(10)
                .borderRadius(10)
              linysText({ text: get_file_suffix(this.text) })
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .padding(10)
                .borderRadius(10)
              linysText({ text: add_units_to_size(get_file_size_Sync(this.text)) })
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .padding(10)
                .borderRadius(10)
            } // Info display
          }
          .borderRadius(10)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .constraintSize(this.tablet_mode ? { maxHeight: this.image_height } : { maxWidth: this.image_width })
          .scrollable(this.tablet_mode ? ScrollDirection.Vertical : ScrollDirection.Horizontal)
          .id('info')
          .margin(this.tablet_mode ? { left: 10 } : { top: 10 })
          .alignRules(this.tablet_mode ?
            {
              top: { anchor: 'image', align: VerticalAlign.Top },
              left: { anchor: 'image', align: HorizontalAlign.End }
            } :
            {
              top: { anchor: 'image', align: VerticalAlign.Bottom },
              left: { anchor: 'image', align: HorizontalAlign.Start }
            })
        }
        .width('auto')
        .height('auto')
        .animation(animation_default())

        Column({ space: 10 }) {
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.save'
          })
            .clickEffect(click_effect_default())
            .onClick(() => {
              this.default_click();
            })
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.magnifyingglass'
          })
            .clickEffect(click_effect_default())
            .onClick(() => {
              // Search online
            })
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.arrow_up_left_and_arrow_down_right'
          })
            .clickEffect(click_effect_default())
            .onClick(() => {
              // Check details
              preview_image(this.text);
            })
        }
      } else {
        linysSymbol({
          symbol_glyph_target: this.type_symbol(),
          font_weight: this.type == "text" ? FontWeight.Regular : FontWeight.Bold,
        }) // Type Symbol

        linysText({
          text: this.text,
          max_lines: 10,
          font_weight: this.type == "text" ? FontWeight.Regular : FontWeight.Bold,
        })// Text display
          .layoutWeight(1)

        Row({ space: 10 }) {
          linysSymbol({
            symbol_glyph_target: this.copied ? 'sys.symbol.checkmark_clipboard_fill' : 'sys.symbol.text_clipboard'
          })// Text copy
            .clickEffect(click_effect_default())
            .onClick(() => {
              this.default_click();
            })

          if (this.type == 'url') {
            linysSymbol({
              symbol_glyph_target: 'sys.symbol.arrow_right'
            })
              .clickEffect(click_effect_default())
              .onClick(() => {
                this.default_click();
              })
          } // Url visit button
        } // Buttons
      } // Content display with Controls
    }
    .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
    .padding(15)
    .borderRadius(20)
    .backgroundColor(this.color_current_primary)
    .justifyContent(FlexAlign.Start)
    .width(this.type == 'image' ? undefined : "100%")
    .visibility(this.this_visibility)
    .offset({ y: this.offset_y })
    .animation(animation_default())
    .onAppear(() => {
      setTimeout(() => {
        this.offset_y = 0;
        this.this_visibility = Visibility.Visible;
      }, Math.min((this.index) * 60, 600))

      setInterval(() => {
        if (this.copied > 0) {
          this.copied -= 10;
        }
        // Reset copy
      }, 10)
    })
    .clickEffect(click_effect_default())
    .onClick(() => {
      this.default_click()
    })
  }

  default_click() {
    if (this.type == 'url') {
      this.new_tab_gateway = this.text;
      this.showing_scratching_board = false;
    }
    if (this.type == 'text') {
      copy(this.text);
      this.copied = animation_popup_duration();
    }
    if (this.type == 'image') {
      document_save_from_uri(this.text);
    }
  }

  type_symbol() {
    if (this.type == 'url') {
      return 'sys.symbol.paperclip';
    }
    if (this.type == 'image') {
      return 'sys.symbol.picture';
    }
    return 'sys.symbol.text_and_t'
  }
}