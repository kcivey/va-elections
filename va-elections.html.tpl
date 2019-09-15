<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>Virginia 2019 Elections</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha256-YLGeXaapI0/5IgZopewRJcFXomhRMlYYjugPLSyNjTY=" crossorigin="anonymous" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.8.1/css/all.min.css" integrity="sha256-7rF6RaSKyh16288E3hVdzQtHyzatA2MQRGu0cf6pqqM=" crossorigin="anonymous" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.19/css/dataTables.bootstrap4.min.css" integrity="sha256-F+DaKAClQut87heMIC6oThARMuWne8+WzxIDT7jXuPA=" crossorigin="anonymous" />
  <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedheader/3.1.5/css/fixedHeader.dataTables.min.css">
  <link rel="stylesheet" href="/index.css" />
  <style type="text/css">
    table {
      background-color: white;
    }
    .democrat {
      font-weight: bold;
      color: white;
      text-align: center;
      background-color: blue;
    }
    .republican {
      font-weight: bold;
      color: white;
      text-align: center;
      background-color: red;
    }
    .empty {
      background-color: #eee;
    }
    #controls {
      position: absolute;
      z-index: 100;
    }
    .control-group {
      display: inline-block;
      margin-right: 1rem;
    }
    #container {
      max-width: 100%;
      overflow-x: scroll;
    }
    #container-top-scroller {
      overflow-x: scroll;
    }
    #container-top-scroller > div {
      height: 20px;
    }
    table.dataTable {
      width: auto;
      margin: 0;
    }
    table.dataTable td {
      white-space: nowrap;
    }
    table.dataTable.fixedHeader-floating {
      margin-top: 0 !important;
    }
    th.rotate {
      height: 135px;
      white-space: nowrap;
    }
    th.rotate > div {
      transform-origin: top left;
      transform: rotate(-45deg);
      width: 30px;
    }
    th.rotate > div > span {
      padding: 6px 0;
    }
    .table td.rotate-spacer {
      border: none;
      padding: 0;
      margin: 0;
    }
    .columns {
      border: #ccc 1px solid;
      padding: 1rem;
      columns: 2 20rem;
      max-width: 70rem;
      column-fill: balance;
      column-gap: 2rem;
      margin-bottom: 1rem;
    }
  </style>
</head>
<body>
<h1>Virginia 2019 Elections</h1>
<div class="columns">
<p>
  The 2017 gubernatorial and 2016 presidential numbers come from
  <a href="https://docs.google.com/spreadsheets/d/1YZRfFiCDBEYB7M18fDGLH8IrmyMQGdQKqpOu9lLvmdo/edit#gid=134618696">a spreadsheet compiled by Daily Kos Elections</a>,
  which has been adjusted for the new district lines, which do not affect Northern Virginia (NoVa). The rest comes from the
  <a href="https://www.vpap.org/elections/">Virginia Public Access Project</a>.
  Margins are calculated from the Democratic and Republican votes, ignoring any votes for other parties or independents.
</p>
<p>
  "Closest NoVa County" means the NoVa county closest to DC that contains part of the district;
  a narrow definition of NoVa is used, going only as far as Prince William and Loudoun Counties.
  Incumbents are marked with an asterisk.
  "Nuttycombe Rating" is from <a href="https://twitter.com/ChazNuttycombe/status/1168567142318596096">Chaz Nuttycombe</a>.
  "Tribbett Rating" is from <a href="https://twitter.com/ChazNuttycombe/status/1168563886024470528">Ben Tribbett</a> (aka Not Larry Sabato).
  Note that Nuttycombe uses a "Tilt" category in his ratings, but Tribbett does not.
  Click the column headers to sort.
</p>
<p>
  In the filtering, "uncontested" races are those that don't have both a Democrat and a Republican (other parties are
  ignored, since there don't seem to be any significant third-party candidates).
  "Possible R→D" means currently Republican-held seats where there is a Democratic candidate running, whether or not
  they have a realistic chance of winning.
  "Competitive" means that Nuttycombe or Tribbett has rated the race as not safe.
</p>
</div>
<div id="container-top-scroller">
  <div></div>
</div>
<div id="container" style="opacity: 0;">
<div id="controls">
  <div class="control-group">
    <div class="form-check form-check-inline">
      <input type="checkbox" id="show-all-columns" class="form-check-input">
      <label class="form-check-label" for="show-all-columns">Show all columns</label>
    </div>
  </div>
  <div class="control-group">
    <div class="form-check form-check-inline">
      <input type="checkbox" id="show-uncontested" class="form-check-input">
      <label class="form-check-label" for="show-uncontested">Show uncontested races too</label>
    </div>
  </div>
  <div class="control-group">
    <div class="form-check form-check-inline">
      <input type="checkbox" id="show-pickups" class="form-check-input">
      <label class="form-check-label" for="show-pickups">Show only possible R→D</label>
    </div>
  </div>
  <div class="control-group">
    <div class="form-check form-check-inline">
      <input type="checkbox" id="show-competitive" class="form-check-input">
      <label class="form-check-label" for="show-competitive">Show only competitive races</label>
    </div>
  </div>
  <div id="show-chamber" class="control-group">
    <div class="form-check form-check-inline">
      <input type="radio" id="show-chamber-1" class="form-check-input" name="chamber" value="senate">
      <label class="form-check-label" for="show-chamber-1">Senate</label>
    </div>
    <div class="form-check form-check-inline">
      <input type="radio" id="show-chamber-2" class="form-check-input" name="chamber" value="house">
      <label class="form-check-label" for="show-chamber-2">House</label>
    </div>
    <div class="form-check form-check-inline">
      <input type="radio" id="show-chamber-3" class="form-check-input" name="chamber" value="both" checked>
      <label class="form-check-label" for="show-chamber-3">Both</label>
    </div>
  </div>
</div>
<table id="races-table" class="table">
  <thead>
    <tr>
      <% _.forEach(headers, function (header) { %>
        <th><%- header %></th>
      <% }); %>
    </tr>
  </thead>
  <tbody>
    <% _.forEach(data, function (r, district) { %>
      <tr>
        <% _.forEach(headers, function (key) { %>
          <% var value = key === 'District' ? district : r[key]; %>
          <td<% if (/Margin|\$/.test(key)) { %> <%= marginStyle((key.includes('(R)') ? -1 : 1) * value, (key.includes('$') && dollarMax)) %><% }
            else if (key === 'VPAP Index') { %> <%= marginStyle(value, 75) %><% }
            else if (/Rating/.test(key)) { %> <%= marginStyle(value * 25) %><% }
            else if (key === 'Party') { %> class="<%= {D: 'democrat', R: 'republican'}[value] || 'empty' %>"<% }
            else if ((Array.isArray(value) && !value.length) || value == null || value === '') { %> class="empty"<% } %>
          >
            <% if (Array.isArray(value)) { %>
              <% _.forEach(value, function (v) { %>
                <%- v %><br>
              <% }); %>
            <% } else { %>
              <%- value %>
            <% } %>
          </td>
        <% }); %>
      </tr>
    <% }); %>
  </tbody>
</table>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.0/jquery.slim.min.js" integrity="sha256-ZaXnYkHGqIhqTbJ6MB4l9Frs/r7U4jlx7ir8PJYBqbI=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.15.0/umd/popper.min.js" integrity="sha256-fTuUgtT7O2rqoImwjrhDgbXTKUwyxxujIMRIK7TbuNU=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha256-CjSoeELFOcH0/uxWu6mC/Vlrc1AARqbm/jiiImDGV3s=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.19/js/jquery.dataTables.min.js" integrity="sha256-t5ZQTZsbQi8NxszC10CseKjJ5QeMw5NINtOXQrESGSU=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.19/js/dataTables.bootstrap4.min.js" integrity="sha256-hJ44ymhBmRPJKIaKRf3DSX5uiFEZ9xB/qx8cNbJvIMU=" crossorigin="anonymous"></script>
<script src="https://cdn.datatables.net/fixedheader/3.1.5/js/dataTables.fixedHeader.min.js"></script>
<script type="text/javascript">
  jQuery(function () {
    const districtCol = {
      width: 20,
      render: function (value, type) {
        if (type === 'sort') {
          const m = value.match(/^([HS]D)(\d+)$/);
          if (m) {
            return m[1] + m[2].padStart(3, '0');
          }
        }
        return value;
      }
    };
    const partyCol= {
      width: 20,
      searchable: false,
    };
    const openCol = {
      className: 'text-center',
      width: 20,
      render: function (value, type) {
        return value === 'true' ? '\u2713' : '';
      },
      searchable: false,
    };
    const numberCol = {
      className: 'text-right',
      visible: false,
      render: $.fn.dataTable.render.number(',', '.'),
      searchable: false,
    };
    const marginCol = {
      className: 'text-right',
      width: 30,
      render: function (value, type) {
        if (value === '') {
          return '';
        }
        value = +value;
        return type === 'display' ? (value > 0 ? '+' : value < 0 ? '\u2212' : '') + Math.abs(value) : value;
      },
      searchable: false,
    };
    const vpapCol = {
        width: 30,
        render: function (value, type) {
            value = +value;
            if (type !== 'display') {
                return value;
            }
            return (value < 0 ? 'R' : 'D') + '+' + Math.abs(value).toFixed(1);
        }
    };
    const hiddenCol = {
        visible: false,
    };
    const nameCol = {
      orderable: false,
    };
    const ratingCol = {
      render: function (value, type) {
          if (type === 'display') {
              return ['Tossup', 'Tilt', 'Lean', 'Likely', 'Safe'][Math.abs(value)] +
                  (value < 0 ? ' R' : value > 0 ? ' D' : '');
          }
          return value;
      },
      searchable: false,
    };
    const dollarCol = {
      className: 'text-right',
      visible: false,
      render: function (value, type) {
        if (type !== 'display') {
          return value;
        }
        const abs = Math.abs(value);
        return (value < 0 ? '\u2212' : '') + (abs ? ((abs < 1000 ? '<1' : Math.round(abs / 1000)) + 'k') : '0');
      },
      searchable: false,
    };
    const dollarAdvantageCol = {
      className: 'text-right',
      render: function (value, type) {
        if (type !== 'display') {
          return value;
        }
        let display = dollarCol.render(value, 'display');
        if (value > 0) {
          display = '+' + display;
        }
        return display;
      },
      searchable: false,
    };
    $.fn.dataTable.ext.search.push(
      function (settings, searchData) {
        if ($('#show-uncontested').prop('checked')) {
          return true;
        }
        return searchData[1] && searchData[2];
      },
      function (settings, searchData) {
        const chamber = $('#show-chamber input:checked').val();
        switch (chamber) {
          case 'house':
            return searchData[0].substr(0, 1) === 'H';
          case 'senate':
            return searchData[0].substr(0, 1) === 'S';
          default:
            return true;
        }
      },
      function (settings, searchData, index, rowData) {
        if (!$('#show-pickups').prop('checked')) {
          return true;
        }
        return rowData[1] && rowData[6] === 'R';
      },
      function (settings, searchData, index, rowData) {
        if (!$('#show-competitive').prop('checked')) {
          return true;
        }
        return Math.abs(rowData[19]) < 4 || Math.abs(rowData[20]) < 4;
      },
    );
    const columns = [
        <% _.forEach(headers, function (header) {
            if (header === 'District') { %>districtCol<% }
            else if (header === 'Party') { %>partyCol<% }
            else if (header === 'Open') { %>openCol<% }
            else if (/\b(?:Votes|D|R)$/.test(header)) { %>numberCol<% }
            else if (/^\$/.test(header)) { %>dollarCol<% }
            else if (/\$ Advantage$/.test(header)) { %>dollarAdvantageCol<% }
            else if (/Margin$/.test(header)) { %>marginCol<% }
            else if (/Rating$/.test(header)) { %>ratingCol<% }
            else if (/VPAP/.test(header)) { %>vpapCol<% }
            else if (/Other|County$/.test(header)) { %>hiddenCol<% }
            else if (/Region/.test(header)) { %>null<% }
            else { %>nameCol<% } %>,
        <% }); %>
    ];
    const $table = $('#races-table')
            .one('draw.dt', () => $('#container').css('opacity', 1))
            .on('draw.dt', function () {
                $('#container-top-scroller div').width($table.width());
            })
            .on('column-visibility.dt', () => $table.columns.adjust().draw());
    adjustTableForRotatedHeads('#races-table');
    const numberOfColumns = $table.find('tr').eq(0).children().length;
    while (numberOfColumns > columns.length) {
        columns.push({searchable: false, sortable: false});
    }
    const table = $table.DataTable({
      columns: columns,
      fixedHeader: true,
      dom: '<"row"<"col-12"f>><"row"<"col-12"tr>><"row"<"col-12"i>>',
      paging: false
    });
    $('#show-uncontested,#show-pickups,#show-competitive').on('click', function () { table.draw(); });
    $('#show-chamber input').on('change', function () { table.draw(); });
    const hiddenColumns = columns.map(function (col, i) { return col && col.visible ? null : i; })
        .filter(function (value) { return value != null; });
    $('#show-all-columns').on('click', function () {
      table.columns(hiddenColumns).visible($(this).prop('checked'));
    });
    $('#container').on('scroll', function () {
      const pos = $(this).scrollLeft();
      $('table[aria-describedby=races-table_info].fixedHeader-floating').css('left', 20 - pos);
      $('#container-top-scroller').scrollLeft(pos);
    });
    $('#container-top-scroller').on('scroll', function () {
      const pos = $(this).scrollLeft();
      $('#container').scrollLeft(pos);
    });
    $(window).on('scroll', function (evt) {
        const pos = $('#container').scrollLeft();
        $('table[aria-describedby=races-table_info].fixedHeader-floating').css('left', 20 - pos);
    });
    function adjustTableForRotatedHeads(table) {
      const $table = $(table);
      const heads = $table.find('thead th');
      if (!heads.is('.rotate')) {
        heads.addClass('rotate')
          .wrapInner('<div><span></span></div>');
      }
      const rad = 45 * Math.PI / 180;
      const sin = Math.sin(rad);
      const cos = Math.cos(rad);
      const tableRight = $table.offset().left + $table.width();
      let maxHeadHeight = 0;
      let maxRight = 0;
      heads.not('.rotate-spacer').each(function () {
        const $head = $(this);
        const $span = $head.find('span');
        const width = $span.outerWidth();
        const height = $span.outerHeight();
        const paddingRight = parseInt($head.css('paddingRight'), 10);
        const actualWidth = Math.abs(width * cos) + Math.abs(height * sin) + paddingRight;
        const actualHeight = Math.abs(width * sin) + Math.abs(height * cos);
        const actualRight = $span.offset().left + actualWidth;
        if (actualHeight > maxHeadHeight) {
          maxHeadHeight = actualHeight;
        }
        if (actualRight > maxRight) {
          maxRight = actualRight;
        }
      });
      heads.height(maxHeadHeight);
      if (!$table.find('.rotate-spacer').length) {
        $table.find('tr').append($('<td/>').addClass('rotate-spacer'));
      }
      const spacerWidth = Math.max(0, maxRight - tableRight);
      $table.find('.rotate-spacer')
        .toggle(spacerWidth > 0)
        .eq(0)
        .html($('<div/>').width(spacerWidth)) // setting td doesn't keep column from collapsing
    }
  });
</script>
<%= '\x3c%= nav %\x3e' %>
</body>
</html>
