import linysSymbol from '../../components/texts/linysSymbol';
import linysText from '../../components/texts/linysText';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default, click_effect_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_history, history_record } from '../../hosts/bunch_of_history';
import woofControlFrame from '../woofControlFrame';
import HistoryDataSource from '../../objects/HistoryDataSource';

@CustomDialog
struct woofHistory {
  controller: CustomDialogController;
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @State scroll_area_height: number = 0;
  @Link showing_settings: boolean;
  // Interactions
  @State viewing_year: number = this.bunch_of_history.get_current_year();
  @State viewing_month: number = this.bunch_of_history.get_current_month();
  // Dates
  @State available_months: number[][] = bunch_of_history.get_history_months();
  @State history_list: history_record[] = this.bunch_of_history.get_history_this_month();
  // Manage
  @State @Watch('on_select_change') selected: boolean[] = this.all_false(this.history_list.length);
  @State selecting: boolean = false;
  @State selected_number: number = 0;
  // alignRules
  alignRules_head_non_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start },
  };
  alignRules_head_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    bottom: { anchor: "controls_history", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start },
  };
  alignRules_foot: AlignRuleOption = {
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
    left: { anchor: "__container__", align: HorizontalAlign.Start }
  };
  alignRules_body_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  alignRules_body_non_tablet: AlignRuleOption = {
    top: { anchor: "title_history", align: VerticalAlign.Bottom },
    bottom: { anchor: "controls_history", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  scroller: Scroller = new Scroller();
  // Data
  private data: HistoryDataSource = new HistoryDataSource(this.bunch_of_history.get_history_this_month());

  build() {
    woofControlFrame({
      title: $r('app.string.Settings_experience_history_view'),
      controller: this.controller
    }) {
      RelativeContainer() {
        Scroll() {
          Column({ space: 15 }) {
            linysText({
              text: $r('app.string.History_desc_1'),
              max_lines: 6
            })
              .width("100%")
              .opacity(0.9)
            linysText({
              text: $r('app.string.History_desc_2'),
              max_lines: 6
            })
              .width("100%")
              .opacity(0.9)
            linysText({
              text: $r('app.string.Have_a_Nice_Surf'),
              max_lines: 2
            })
              .width("100%")
              .opacity(0.9)
          } // Title
          .width("100%")
        } // Title and descriptions
        .scrollBar(BarState.Off)
        .align(Alignment.TopStart)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ bottom: 10, right: this.tablet_mode ? 10 : 0 })
        .width(this.tablet_mode ? "35%" : "100%")
        .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
        .animation(animation_default())
        .id("title_history")

        Column({ space: 10 }) {

          Row() {
            linysText({
              text: $r('app.string.Settings_experience_history_date_format'),
              font_weight: FontWeight.Bold
            })
              .opacity(0.7)
            linysText({ text: " (" + this.history_list.length.toString() + ")" })
              .opacity(0.7)
          } // Time elapse description
          .width("100%")

          Scroll() {
            List({ scroller: this.scroller }) {
              LazyForEach(this.data, (_record_item: history_record, key: number) => {
                ListItem() {
                  // linysText({ text: key.toString() })
                  if (this.history_list[this.history_list.length - 1 - key]) {
                    meowRelation({
                      index: this.history_list.length - 1 - key,
                      show: this.showing_settings,
                      selected: this.selected,
                      selected_number: this.selected_number,
                      selecting: this.selecting,
                      label_link: this.history_list[this.history_list.length - 1 - key],
                      controller: this.controller,
                    })
                      .width("100%")
                  }
                }
              }, (item: history_record) => item.accessed_time.toString() + this.history_list.length.toString()) // Items

              if (this.history_list.length == 0) {
                linysTextTitle({
                  text: "¯\\_(ツ)_/¯"
                })
                  .margin(30)
                  .opacity(0.7)
                  .animation(animation_default())
              }
            }
            .width("100%")
            .height("100%")
          } // Main history list
          .padding({ bottom: 5 })
          .scrollable(ScrollDirection.Vertical)
          .edgeEffect(EdgeEffect.Spring)
          .onAreaChange((_o, n) => {
            this.scroll_area_height = n.height as number;
          })
          .align(Alignment.Top)
          .layoutWeight(1)
          .width("100%")
          .borderRadius(13.5)
          .backgroundColor(this.color_current_secondary)

          Scroll() {
            Row({ space: 5 }) {
              ForEach(this.available_months, (item: number[], _key: number) => {
                month_button({
                  year: item[0],
                  month: item[1],
                  viewing_year: this.viewing_year,
                  viewing_month: this.viewing_month,
                })
                  .onClick(() => {
                    // MEOW
                    this.bunch_of_history.open_month_from_disk_sync(item[0], item[1]);
                    this.refresh_current_history_list();
                    this.viewing_year = item[0];
                    this.viewing_month = item[1];
                    this.scroller.scrollToIndex(0, false);
                    this.data.setData(this.bunch_of_history.get_history_this_month());
                  })
              }) // Items
            }
          } // Available months
          .scrollable(ScrollDirection.Horizontal)
          .edgeEffect(EdgeEffect.Spring)
          .onAreaChange((_o, n) => {
            this.scroll_area_height = n.height as number;
          })
          .padding(5)
          .align(Alignment.Start)
          .width("100%")
          .borderRadius(13.5)
          .backgroundColor(this.color_current_secondary)

        } // List
        .width(this.tablet_mode ? "65%" : "100%")
        .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)
        .animation(animation_default())

        Column() {
          Scroll() {
            Column({ space: 10 }) {
              Row() {
                linysTextTitle({ text: $r("app.string.Settings_edit_selecting") })
                linysTextTitle({ text: " " + this.selected_number.toString() + " " })
                linysTextTitle({ text: $r("app.string.Settings_edit_selecting_items") })
              } // Selecting ... item(s)
              Row() {
                linysSymbol({ symbol_glyph_target: 'sys.symbol.list_checkmask' })
                  .onClick(() => {
                    this.select_all();
                  })
                Blank()
                linysTimeoutButton({
                  text: "  󰀁  ",
                  onExecution: () => {
                    this.delete_selected();
                  }
                }) // Delete
              } // Buttons
              .width("100%")
            }
            .padding({ top: 10, right: this.tablet_mode ? 10 : 0, bottom: 5 })
            .alignItems(HorizontalAlign.Start)
            .width("100%")
            .animation(animation_default())
          } // Select controls
          .scrollBar(BarState.Off)
          .width("100%")
          .height(this.selecting ? 80 : 0)
          .animation(animation_default())
        } // Controls
        .alignItems(HorizontalAlign.End)
        .id("controls_history")
        .alignRules(this.alignRules_foot)
        .animation(animation_default())
        .width(this.tablet_mode ? "35%" : "100%")
      }
      .layoutWeight(1)
    }
  }

  // Utils

  /**
   * Constructs and returns a boolean list of specified length consists of false.
   * @param length A number, the length of the list.
   * @returns A boolean[] array, all elements are false.
   * */
  all_false(length: number) {
    let result: boolean[] = [];
    for (let index = 0; index < length; index++) {
      result.push(false);
    }
    return result;
  }

  // Select Events and operations

  /**
   * Triggered when selecting or unselecting a history.
   *
   * Sets this.selecting to true, if is selecting something.
   *
   * Otherwise set it to false.
   *
   * @abstract Also resets this.delete_confirm.
   * */
  on_select_change() {
    if (this.selected.includes(true)) {
      this.selecting = true;
    } else {
      this.selecting = false;
    }
  }

  /**
   * Refreshes this.history_list according to the time range selected.
   * */
  refresh_current_history_list() {
    this.history_list = this.bunch_of_history.get_history_this_month();
    this.selected_number = 0;
    this.selected = this.all_false(this.history_list.length);
  }

  /**
   * One click to select or unselect all history records.
   *
   * @abstract If there is still items unselected, then selects all.
   * If all items are already selected, then unselect all.
   * */
  select_all() {
    let new_selected: boolean[] = [];
    if (this.selected.includes(false)) {
      for (let index = 0; index < this.selected.length; index++) {
        new_selected.push(true);
      }
      this.selected_number = this.selected.length;
    } else {
      for (let index = 0; index < this.selected.length; index++) {
        new_selected.push(false);
      }
      this.selected_number = 0;
    }
    this.selected = new_selected;
  }

  /**
   * Deletes all items selected, and refreshes the current history list according to time range specified.
   *
   * @abstract Also reconstructs the plain history cache and saves the operated history to sandbox storage.
   * */
  delete_selected() {
    let indices: number[] = [];
    for (let index = 0; index < this.selected.length; index++) {
      if (this.selected[index]) {
        indices.push(index);
        // Notify LazyForEach
        // this.data.notifyDataDelete(indices[index]);

        // TODO: use better strategy to notify LazyForEach about a deletion.
        this.data.setData(this.bunch_of_history.get_history_this_month());
      }
    }
    this.bunch_of_history.remove_histories_at_indices(this.viewing_year, this.viewing_month, indices, true);
    this.refresh_current_history_list();
  }
}

export default woofHistory;

@Component
struct meowRelation {
  // Base
  controller: CustomDialogController | undefined;
  @Prop index: number;
  @Prop label_link: history_record;
  @Link show: boolean;
  @Link selected: boolean[];
  @Link selected_number: number;
  @Prop selecting: boolean;
  // UI Effects
  @Prop scroll_area_height: number;
  @Prop human_time: string = new Date(this.label_link.accessed_time).toLocaleString();
  // Gateways
  @StorageLink('universal_new_tab_gateway') universal_new_tab_gateway: string = "";
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 2 }) {
      linysText({
        color: this.selected[this.index] ? this.color_current_secondary : this.color_current_font,
        text: this.label_link.label.length == 0 ? "　" : this.label_link.label,
        font_weight: this.selected[this.index] ? FontWeight.Bold : FontWeight.Regular
      })
      linysText({
        color: this.selected[this.index] ? this.color_current_secondary : this.color_current_font,
        text: this.label_link.link,
        max_lines: 2
      })
        .opacity(0.88) // Happy New Year!
      linysText({
        color: this.selected[this.index] ? this.color_current_secondary : this.color_current_font,
        text: this.human_time
      })
        .opacity(0.7)
    }
    .padding({
      left: 12,
      right: 12,
      top: 9,
      bottom: 3
    })
    .alignItems(HorizontalAlign.Start)
    .width("100%")
    .backgroundColor(this.selected[this.index] ? this.color_current_font : this.color_current_secondary)
    .animation(animation_default())
    .onClick(() => {
      if (this.selecting) {
        // Select
        this.select_unselect();
        return;
      }
      this.universal_new_tab_gateway = this.label_link.link;
      if (this.controller) {
        this.show = false;
        this.controller.close();
      }
    })
    .clickEffect(click_effect_default())
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.select_unselect();
        })
    )
    .onMouse((e) => {
      if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
        // Right click
        this.select_unselect();
      }
    })
  }

  /**
   * Selects or unselects myself, usually called when onClick.
   * */
  select_unselect() {
    if (this.selected[this.index]) {
      this.selected_number -= 1;
    } else {
      this.selected_number += 1;
    }
    this.selected[this.index] = !this.selected[this.index];
  }
}

@Component
struct month_button {
  @Prop year: number;
  @Prop month: number;
  @Link viewing_year: number;
  @Link viewing_month: number;
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 0 }) {
      linysText({
        text: this.year.toString(),
        font_weight: this.selected() ? FontWeight.Bold : FontWeight.Regular,
      })
      linysText({
        text: this.month.toString(),
        font_weight: this.selected() ? FontWeight.Bold : FontWeight.Regular,
      })
    }
    .border({ color: this.selected() ? this.color_current_font : 'transparent', width: 2, radius: 10 })
    .alignItems(HorizontalAlign.Start)
    .clickEffect(click_effect_default())
    .padding(8)
    .backgroundColor(this.color_current_primary)
    .animation(animation_default())
  }

  selected() {
    return this.month == this.viewing_month && this.year == this.viewing_year;
  }
}
