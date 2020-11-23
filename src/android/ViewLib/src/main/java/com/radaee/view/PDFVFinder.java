package com.radaee.view;

import com.radaee.pdf.*;
import com.radaee.pdf.Page.Finder;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Style;

/**
Inner class.<br/>
developer should not use this.
*/
@Deprecated
public class PDFVFinder
{
	private String m_str = null;
	private boolean m_case = false;
	private boolean m_whole = false;
	private int m_page_no = -1;
	private int m_page_find_index = -1;
	private int m_page_find_cnt = 0;
	private Page m_page = null;
	private Document m_doc = null;
	
	private Finder m_finder = null;
	
	private int m_dir = 0;
	private boolean is_cancel = true;
	private boolean is_notified = false;
	private boolean is_waitting = false;
	private Paint m_paint = new Paint();
	protected PDFVFinder()
	{
		m_paint.setARGB((Global.findPrimaryColor>>24)&0xFF, (Global.findPrimaryColor>>16)&0xFF, (Global.findPrimaryColor>>8)&0xFF,
				Global.findPrimaryColor&0xFF );
		m_paint.setStyle(Style.FILL);
	}
	private synchronized void eve_reset()
	{
		is_notified = false;
		is_waitting = false;
	}
	private synchronized void eve_wait()
	{
		try
		{
			if( is_notified )
				is_notified = false;
			else
			{
				is_waitting = true;
				wait();
				is_waitting = false;
			}
		}
		catch(Exception e)
		{
		}
	}
	private synchronized void eve_notify()
	{
		if( is_waitting )
			notify();
		else
			is_notified = true;
	}
	protected void find_start(Document doc, int page_start, String str, boolean match_case, boolean whole)
	{
		m_str = str;
		m_case = match_case;
		m_whole = whole;
		m_doc = doc;
		m_page_no = page_start;
		if( m_page != null )
		{
			if( m_finder != null )
			{
				m_finder.Close();
				m_finder = null;
			}
			m_page.Close();
			m_page = null;
		}
		m_page_find_index = -1;
		m_page_find_cnt = 0;
	}
	protected int find_prepare(int dir)
	{
		if( m_str == null ) return 0;
		if( !is_cancel ) eve_wait();
		m_dir = dir;
		eve_reset();
		if( m_page == null )
		{
			is_cancel = false;
			return -1;
		}
		is_cancel = true;
		if( dir < 0 )
		{
			if( m_page_find_index >= 0) m_page_find_index--;
			if( m_page_find_index < 0 )
			{
				if( m_page_no <= 0 )
				{
					return 0;
				}
				else
				{
					is_cancel = false;
					return -1;
				}
			}
			else
				return 1;
		}
		else
		{
			if( m_page_find_index < m_page_find_cnt ) m_page_find_index++;
			if( m_page_find_index >= m_page_find_cnt )
			{
				if( m_page_no >= m_doc.GetPageCount() - 1 )
				{
					return 0;
				}
				else
				{
					is_cancel = false;
					return -1;
				}
			}
			else
				return 1;
		}
	}
	protected int find()
	{
		int ret = 0;
		int pcnt = m_doc.GetPageCount();
		if( m_dir < 0 )
		{
			while( (m_page == null || m_page_find_index < 0) && m_page_no >= 0 && !is_cancel )
			{
				if( m_page == null )
				{
					if( m_page_no >= pcnt ) m_page_no = pcnt - 1;
					m_page = m_doc.GetPage(m_page_no);
					m_page.ObjsStart();
					m_finder = m_page.FindOpen(m_str, m_case, m_whole);
					if( m_finder == null ) m_page_find_cnt = 0;
					else m_page_find_cnt = m_finder.GetCount();
					m_page_find_index = m_page_find_cnt - 1;
				}
				if( m_page_find_index < 0 )
				{
					if( m_finder != null )
					{
						m_finder.Close();
						m_finder = null;
					}
					m_page.Close();
					m_page = null;
					m_page_find_cnt = 0;
					m_page_no--;
				}
			}
			if( is_cancel || m_page_no < 0 )
			{
				if( m_finder != null )
				{
					m_finder.Close();
					m_finder = null;
				}
				if( m_page != null )
				{
					m_page.Close();
					m_page = null;
				}
				ret = 0;//find error, notify UI process
			}
			else
				ret = 1;//find finished, notify UI process
		}
		else
		{
			while( (m_page == null || m_page_find_index >= m_page_find_cnt) && m_page_no < pcnt && !is_cancel )
			{
				if( m_page == null )
				{
					if( m_page_no < 0 ) m_page_no = 0;
					m_page = m_doc.GetPage(m_page_no);
					m_page.ObjsStart();
					m_finder = m_page.FindOpen(m_str, m_case, m_whole);
					if( m_finder == null ) m_page_find_cnt = 0;
					else m_page_find_cnt = m_finder.GetCount();
					m_page_find_index = 0;
				}
				if( m_page_find_index >= m_page_find_cnt )
				{
					if( m_finder != null )
					{
						m_finder.Close();
						m_finder = null;
					}
					m_page.Close();
					m_page = null;
					m_page_find_cnt = 0;
					m_page_no++;
				}
			}
			if( is_cancel || m_page_no >= pcnt )
			{
				if( m_finder != null )
				{
					m_finder.Close();
					m_finder = null;
				}
				if( m_page != null )
				{
					m_page.Close();
					m_page = null;
				}
				ret = 0;////find error, notify UI process
			}
			else
				ret = 1;//find finished, notify UI process
		}
		eve_notify();
		return ret;
	}
	protected float [] find_get_pos()//get current found's bound.
	{
		if( m_finder != null )
		{
			int ichar = m_finder.GetFirstChar(m_page_find_index);
			if( ichar < 0 ) return null;
			float rect[] = new float[4];
			m_page.ObjsGetCharRect(ichar, rect);
			return rect;
		}
		else
			return null;
	}
	protected void find_draw( BMP bmp, PDFVPage page, int scrollx, int scrolly )//draw current found
	{
		if( !is_cancel )
		{
			eve_wait();
			is_cancel = true;
		}
		if( m_str == null ) return;
		if( m_finder != null && m_page_find_index >= 0 && m_page_find_index < m_page_find_cnt )
		{
			int ichar = m_finder.GetFirstChar(m_page_find_index);
			int ichar_end = ichar + m_str.length();
			float rect[] = new float[4];
			float rect_word[] = new float[4];
			float rect_draw[] = new float[4];
			m_page.ObjsGetCharRect(ichar, rect);
			rect_word[0] = rect[0];
			rect_word[1] = rect[1];
			rect_word[2] = rect[2];
			rect_word[3] = rect[3];
			ichar++;
			while( ichar < ichar_end )
			{
				m_page.ObjsGetCharRect(ichar, rect);
				float gap = (rect[3] - rect[1])/2;
				if( rect_word[1] == rect[1] && rect_word[3] == rect[3] &&
					rect_word[2] + gap > rect[0] && rect_word[0] - gap < rect[2] )
				{
					if( rect_word[0] > rect[0] ) rect_word[0] = rect[0];
					if( rect_word[2] < rect[2] ) rect_word[2] = rect[2];
				}
				else
				{
					rect_draw[0] = page.ToDIBX(rect_word[0]) + page.GetX() - scrollx;
					rect_draw[1] = page.ToDIBY(rect_word[3]) + page.GetY() - scrolly;
					rect_draw[2] = page.ToDIBX(rect_word[2]) + page.GetX() - scrollx;
					rect_draw[3] = page.ToDIBY(rect_word[1]) + page.GetY() - scrolly;
					bmp.DrawRect(0x400000FF, (int)rect_draw[0], (int)rect_draw[1], (int)(rect_draw[2] - rect_draw[0]), (int)(rect_draw[3] - rect_draw[1]), 0);
					rect_word[0] = rect[0];
					rect_word[1] = rect[1];
					rect_word[2] = rect[2];
					rect_word[3] = rect[3];
				}
				ichar++;
			}
			rect_draw[0] = page.ToDIBX(rect_word[0]) + page.GetX() - scrollx;
			rect_draw[1] = page.ToDIBY(rect_word[3]) + page.GetY() - scrolly;
			rect_draw[2] = page.ToDIBX(rect_word[2]) + page.GetX() - scrollx;
			rect_draw[3] = page.ToDIBY(rect_word[1]) + page.GetY() - scrolly;
			bmp.DrawRect(0x400000FF, (int)rect_draw[0], (int)rect_draw[1], (int)(rect_draw[2] - rect_draw[0]), (int)(rect_draw[3] - rect_draw[1]), 0);
		}
	}
	protected void find_draw_to_dib( DIB dib, PDFVPage page, int scrollx, int scrolly )//draw current found
	{
		if( !is_cancel )
		{
			eve_wait();
			is_cancel = true;
		}
		if( m_str == null ) return;
		if( m_finder != null && m_page_find_index >= 0 && m_page_find_index < m_page_find_cnt )
		{
			int ichar = m_finder.GetFirstChar(m_page_find_index);
			int ichar_end = ichar + m_str.length();
			float rect[] = new float[4];
			float rect_word[] = new float[4];
			float rect_draw[] = new float[4];
			m_page.ObjsGetCharRect(ichar, rect);
			rect_word[0] = rect[0];
			rect_word[1] = rect[1];
			rect_word[2] = rect[2];
			rect_word[3] = rect[3];
			ichar++;
			while( ichar < ichar_end )
			{
				m_page.ObjsGetCharRect(ichar, rect);
				float gap = (rect[3] - rect[1])/2;
				if( rect_word[1] == rect[1] && rect_word[3] == rect[3] &&
					rect_word[2] + gap > rect[0] && rect_word[0] - gap < rect[2] )
				{
					if( rect_word[0] > rect[0] ) rect_word[0] = rect[0];
					if( rect_word[2] < rect[2] ) rect_word[2] = rect[2];
				}
				else
				{
					rect_draw[0] = page.ToDIBX(rect_word[0]) + page.GetX() - scrollx;
					rect_draw[1] = page.ToDIBY(rect_word[3]) + page.GetY() - scrolly;
					rect_draw[2] = page.ToDIBX(rect_word[2]) + page.GetX() - scrollx;
					rect_draw[3] = page.ToDIBY(rect_word[1]) + page.GetY() - scrolly;
					dib.DrawRect(0x400000FF, (int)rect_draw[0], (int)rect_draw[1], (int)(rect_draw[2] - rect_draw[0]), (int)(rect_draw[3] - rect_draw[1]), 0);
					rect_word[0] = rect[0];
					rect_word[1] = rect[1];
					rect_word[2] = rect[2];
					rect_word[3] = rect[3];
				}
				ichar++;
			}
			rect_draw[0] = page.ToDIBX(rect_word[0]) + page.GetX() - scrollx;
			rect_draw[1] = page.ToDIBY(rect_word[3]) + page.GetY() - scrolly;
			rect_draw[2] = page.ToDIBX(rect_word[2]) + page.GetX() - scrollx;
			rect_draw[3] = page.ToDIBY(rect_word[1]) + page.GetY() - scrolly;
			dib.DrawRect(0x400000FF, (int)rect_draw[0], (int)rect_draw[1], (int)(rect_draw[2] - rect_draw[0]), (int)(rect_draw[3] - rect_draw[1]), 0);
		}
	}
	protected void find_draw( Canvas canvas, PDFVPage page, int scrollx, int scrolly )//draw current found
	{
		if( !is_cancel )
		{
			eve_wait();
			is_cancel = true;
		}
		if( m_str == null ) return;
		if( m_finder != null && m_page_find_index >= 0 && m_page_find_index < m_page_find_cnt )
		{
			int ichar = m_finder.GetFirstChar(m_page_find_index);
			int ichar_end = ichar + m_str.length();
			float rect[] = new float[4];
			float rect_word[] = new float[4];
			float rect_draw[] = new float[4];
			m_page.ObjsGetCharRect(ichar, rect);
			rect_word[0] = rect[0];
			rect_word[1] = rect[1];
			rect_word[2] = rect[2];
			rect_word[3] = rect[3];
			ichar++;
			while( ichar < ichar_end )
			{
				m_page.ObjsGetCharRect(ichar, rect);
				float gap = (rect[3] - rect[1])/2;
				if( rect_word[1] == rect[1] && rect_word[3] == rect[3] &&
					rect_word[2] + gap > rect[0] && rect_word[0] - gap < rect[2] )
				{
					if( rect_word[0] > rect[0] ) rect_word[0] = rect[0];
					if( rect_word[2] < rect[2] ) rect_word[2] = rect[2];
				}
				else
				{
					rect_draw[0] = page.ToDIBX(rect_word[0]) + page.GetX() - scrollx;
					rect_draw[1] = page.ToDIBY(rect_word[3]) + page.GetY() - scrolly;
					rect_draw[2] = page.ToDIBX(rect_word[2]) + page.GetX() - scrollx;
					rect_draw[3] = page.ToDIBY(rect_word[1]) + page.GetY() - scrolly;
					canvas.drawRect(rect_draw[0], rect_draw[1], rect_draw[2], rect_draw[3], m_paint);
					rect_word[0] = rect[0];
					rect_word[1] = rect[1];
					rect_word[2] = rect[2];
					rect_word[3] = rect[3];
				}
				ichar++;
			}
			rect_draw[0] = page.ToDIBX(rect_word[0]) + page.GetX() - scrollx;
			rect_draw[1] = page.ToDIBY(rect_word[3]) + page.GetY() - scrolly;
			rect_draw[2] = page.ToDIBX(rect_word[2]) + page.GetX() - scrollx;
			rect_draw[3] = page.ToDIBY(rect_word[1]) + page.GetY() - scrolly;
			canvas.drawRect(rect_draw[0], rect_draw[1], rect_draw[2], rect_draw[3], m_paint);
		}
	}
	protected int find_get_page()//get current found's page NO
	{
		return m_page_no;
	}
	protected void find_end()
	{
		if( !is_cancel )
		{
			is_cancel = true;
			eve_wait();
		}
		m_str = null;
		if( m_page != null )
		{
			if( m_finder != null )
			{
				m_finder.Close();
				m_finder = null;
			}
			m_page.Close();
			m_page = null;
		}
	}
}
